
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'mcp_oauth_helper.dart';
import '../core/models/tool.dart';
import '../core/models/ai_tool.dart'; // For AiToolCall

// Represents the capabilities of the client.
class McpClientCapabilities {
  Map<String, dynamic> toJson() => {};
}

// Represents information about the client implementation.
class McpClientInfo {
  final String name;
  final String? version;

  McpClientInfo({required this.name, this.version});

  Map<String, dynamic> toJson() => {
        'name': name,
        if (version != null) 'version': version,
      };
}

typedef UserAuthCallback = Future<String> Function(Uri authorizationUri);

class McpClient {
  final String baseUrl;
  final http.Client _httpClient;
  final McpOauthHelper? _oauthHelper;
  final UserAuthCallback? _userAuthCallback;

  String? _accessToken;
  int _requestId = 1;

  McpClient({
    required this.baseUrl,
    http.Client? httpClient,
    McpOauthHelper? oauthHelper,
    UserAuthCallback? userAuthCallback,
  })  : _httpClient = httpClient ?? http.Client(),
        _oauthHelper = oauthHelper,
        _userAuthCallback = userAuthCallback;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  Future<Map<String, dynamic>> _sendRequest(String method, [Map<String, dynamic>? params, bool isRetry = false]) async {
    final url = Uri.parse(baseUrl);
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    final body = jsonEncode({
      'jsonrpc': '2.0',
      'method': method,
      'params': params ?? {},
      'id': _requestId++,
    });

    final response = await _httpClient.post(url, headers: headers, body: body);

    if (response.statusCode == 401 && !isRetry) {
      if (_oauthHelper != null && _userAuthCallback != null) {
        return await _handleUnauthorized(method, params);
      } else {
        throw Exception('Received 401 Unauthorized but no OAuth helper is configured.');
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data['error'] != null) {
        throw Exception('MCP Error: ${data['error']['message']} (Code: ${data['error']['code']})');
      }
      return data['result'];
    } else {
      throw http.ClientException('HTTP Error: ${response.statusCode} - ${response.body}', response.request?.url);
    }
  }

  Future<Map<String, dynamic>> _handleUnauthorized(String originalMethod, Map<String, dynamic>? originalParams) async {
    final authUrl = await _oauthHelper!.getAuthorizationUrl();
    final authCode = await _userAuthCallback!(Uri.parse(authUrl));
    final newAccessToken = await _oauthHelper!.exchangeAuthorizationCode(authCode);
    setAccessToken(newAccessToken);

    print("Authentication successful. Retrying original request...");
    return await _sendRequest(originalMethod, originalParams, true);
  }

  Future<Map<String, dynamic>> initialize({
    required String protocolVersion,
    McpClientCapabilities? capabilities,
    required McpClientInfo clientInfo,
  }) {
    return _sendRequest('initialize', {
      'protocolVersion': protocolVersion,
      'capabilities': capabilities?.toJson() ?? {},
      'clientInfo': clientInfo.toJson(),
    });
  }

  Future<void> initialized() async {
     final url = Uri.parse(baseUrl);
     final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    final body = jsonEncode({
      'jsonrpc': '2.0',
      'method': 'notifications/initialized',
    });

    final response = await _httpClient.post(url, headers: headers, body: body);
     if (response.statusCode < 200 || response.statusCode >= 300) {
        throw http.ClientException('HTTP Error on initialized notification: ${response.statusCode}', response.request?.url);
    }
  }

  Future<List<AiTool>> getTools() async {
    final result = await _sendRequest('tools/list');
    if (result['tools'] is List) {
      return (result['tools'] as List).map((toolJson) {
        return AiTool(
          name: toolJson['name'],
          description: toolJson['description'] ?? '',
          parameters: toolJson['inputSchema'] as Map<String, dynamic>? ?? {},
        );
      }).toList();
    }
    throw Exception('Invalid response format for tools/list: "tools" list not found');
  }

  Future<Map<String, dynamic>> callTool(String name, Map<String, dynamic> arguments) {
     return _sendRequest('tools/call', {
      'name': name,
      'arguments': arguments,
    });
  }
}
