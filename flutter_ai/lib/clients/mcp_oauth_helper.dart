
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:oauth2_client/oauth2_client.dart';
import 'package:pkce/pkce.dart';

class McpOauthHelper {
  final String clientId;
  final String? clientSecret;
  final List<String> scopes;
  final String mcpServerUrl;
  final String? redirectUri;

  late OAuth2Client _oauth2Client;
  PkcePair _pkcePair = PkcePair.generate();

  McpOauthHelper({
    required this.clientId,
    this.clientSecret,
    required this.scopes,
    required this.mcpServerUrl,
    this.redirectUri,
  });

  /// 1. Discover Authorization Server Metadata
  Future<void> _discoverEndpoints() async {
    // First, try the WWW-Authenticate header from a 401 response.
    // This part will be integrated into the main client's error handling.
    // For now, we assume we have the metadata URL.

    // As a placeholder, we'll construct the well-known URL.
    final wellKnownUrl = Uri.parse(mcpServerUrl).replace(path: '/.well-known/oauth-protected-resource');

    final metadataResponse = await http.get(wellKnownUrl);
    if (metadataResponse.statusCode != 200) {
      throw Exception('Failed to discover protected resource metadata.');
    }
    final resourceMetadata = jsonDecode(metadataResponse.body);
    final authServerUrl = resourceMetadata['authorization_servers'].first;

    // Now discover the auth server's endpoints (OIDC or OAuth2 metadata)
     final oidcConfigUrl = Uri.parse(authServerUrl).replace(path: '/.well-known/openid-configuration');
    final authServerMetaResponse = await http.get(oidcConfigUrl);
     if (authServerMetaResponse.statusCode != 200) {
      throw Exception('Failed to discover authorization server metadata.');
    }
    final authServerMetadata = jsonDecode(authServerMetaResponse.body);

    _oauth2Client = OAuth2Client(
      authorizeUrl: authServerMetadata['authorization_endpoint'],
      tokenUrl: authServerMetadata['token_endpoint'],
      redirectUri: redirectUri,
      customUriScheme: 'http',
      clientId: clientId,
      clientSecret: clientSecret,
    );
  }

  /// 2. Get the Authorization URL for the user
  Future<String> getAuthorizationUrl() async {
    await _discoverEndpoints();
    return _oauth2Client.getAuthorizeUrl(
      customParams: {
        'code_challenge': _pkcePair.codeChallenge,
        'code_challenge_method': 'S256',
        'resource': mcpServerUrl,
      },
      scopes: scopes,
    );
  }

  /// 3. Exchange the Authorization Code for an Access Token
  Future<String> exchangeAuthorizationCode(String code) async {
    final response = await _oauth2Client.getTokenWithAuthCodeFlow(
      authCode: code,
      codeVerifier: _pkcePair.codeVerifier,
    );

    if (response.accessToken != null) {
      return response.accessToken!;
    } else {
      throw Exception('Failed to get access token.');
    }
  }
}
