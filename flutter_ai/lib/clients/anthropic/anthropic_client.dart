import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/messages_request.dart';
import 'models/messages_response.dart';
import 'package:flutter_ai/core/ai_provider.dart';
import 'package:flutter_ai/core/models/ai_message.dart';
import 'package:flutter_ai/core/models/ai_response.dart';

/// A client for interacting with the Anthropic API.
class AnthropicClient implements AiProvider {
  @override
  String get providerId => 'anthropic';

  final String? apiKey;
  final String baseUrl;
  final String apiVersion;
  final Map<String, String>? headers;
  final http.Client _httpClient;

  AnthropicClient({
    this.apiKey,
    this.baseUrl = 'https://api.anthropic.com/v1',
    this.apiVersion = '2023-06-01',
    this.headers,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Map<String, String> _buildHeaders() {
    final finalHeaders = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'anthropic-version': apiVersion,
    };
    if (apiKey != null) {
      finalHeaders['x-api-key'] = apiKey!;
    }
    if (headers != null) {
      finalHeaders.addAll(headers!);
    }
    return finalHeaders;
  }

  Future<AnthropicMessagesResponse> createMessage(AnthropicMessagesRequest request) async {
    final url = '$baseUrl/messages';
    final response = await _httpClient.post(Uri.parse(url), headers: _buildHeaders(), body: json.encode(request.toJson()));
    if (response.statusCode == 200) {
      return AnthropicMessagesResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create message: ${response.statusCode} ${response.body}');
    }
  }

  Stream<AnthropicMessagesStreamEvent> createMessageStream(AnthropicMessagesRequest request) {
    final url = '$baseUrl/messages';
    final controller = StreamController<AnthropicMessagesStreamEvent>();
    final httpRequest = http.Request('POST', Uri.parse(url))..headers.addAll(_buildHeaders())..body = json.encode(request.toJson()..['stream'] = true);
    _httpClient.send(httpRequest).then((streamedResponse) {
      streamedResponse.stream.transform(utf8.decoder).listen((data) {
        final lines = data.split('\n');
        String? eventType;
        for (final line in lines) {
          if (line.startsWith('event: ')) {
            eventType = line.substring(7).trim();
          } else if (line.startsWith('data: ') && eventType != null) {
            final jsonString = line.substring(6).trim();
            try {
              controller.add(AnthropicMessagesStreamEvent(type: eventType, data: json.decode(jsonString)));
            } catch (e) {
              // Ignore
            }
            eventType = null;
          }
        }
      }, onError: controller.addError, onDone: controller.close);
    }).catchError(controller.addError);
    return controller.stream;
  }

  void close() {
    _httpClient.close();
  }

  @override
  Future<AiChatResponse> createChat(List<AiMessage> messages, {Map<String, dynamic> options = const {}}) async {
    final systemPrompt = messages.firstWhere((m) => m.role == AiMessageRole.system, orElse: () => AiMessage.system('')).parts.whereType<AiTextContent>().map((p) => p.text).join();
    final userMessages = messages.where((m) => m.role != AiMessageRole.system).toList();

    final request = AnthropicMessagesRequest(
      model: options['model'] ?? 'claude-3-opus-20240229',
      messages: userMessages,
      system: systemPrompt.isNotEmpty ? systemPrompt : null,
      maxTokens: options['maxTokens'] ?? 1024,
      temperature: options['temperature'],
    );
    final response = await createMessage(request);
    final textContent = response.content.where((c) => c['type'] == 'text').map((c) => c['text']).join();
    return AiChatResponse(
      id: response.id,
      model: response.model,
      message: AiMessage.assistant(textContent),
    );
  }

  @override
  Stream<AiChatResponseChunk> createChatStream(List<AiMessage> messages, {Map<String, dynamic> options = const {}}) {
    final systemPrompt = messages.firstWhere((m) => m.role == AiMessageRole.system, orElse: () => AiMessage.system('')).parts.whereType<AiTextContent>().map((p) => p.text).join();
    final userMessages = messages.where((m) => m.role != AiMessageRole.system).toList();

    final request = AnthropicMessagesRequest(
      model: options['model'] ?? 'claude-3-opus-20240229',
      messages: userMessages,
      system: systemPrompt.isNotEmpty ? systemPrompt : null,
      maxTokens: options['maxTokens'] ?? 1024,
      temperature: options['temperature'],
      stream: true,
    );
    return createMessageStream(request)
        .where((event) => event.textDelta != null)
        .map((event) => AiChatResponseChunk(content: event.textDelta));
  }
}
