import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/chat_request.dart';
import 'models/chat_response.dart';
import 'package:flutter_ai/core/ai_provider.dart';
import 'package:flutter_ai/core/models/ai_message.dart';
import 'package:flutter_ai/core/models/ai_response.dart';

/// A client for interacting with the Ollama API.
class OllamaClient implements AiProvider {
  @override
  String get providerId => 'ollama';

  final String baseUrl;
  final Map<String, String>? headers;
  final http.Client _httpClient;

  OllamaClient({
    this.baseUrl = 'https://ollama.com/api',
    this.headers,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Map<String, String> _buildHeaders() {
    final finalHeaders = <String, String>{'Content-Type': 'application/json; charset=utf-8'};
    if (headers != null) {
      finalHeaders.addAll(headers!);
    }
    return finalHeaders;
  }

  // Internal method for Ollama-specific chat request.
  Future<OllamaChatResponse> _createChatInternal(OllamaChatRequest request) async {
    final url = '$baseUrl/chat';
    final response = await _httpClient.post(Uri.parse(url), headers: _buildHeaders(), body: json.encode(request.toJson()));
    if (response.statusCode == 200) {
      return OllamaChatResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create chat: ${response.statusCode} ${response.body}');
    }
  }

  // Internal method for Ollama-specific streamed chat request.
  Stream<OllamaChatResponse> _createChatStreamInternal(OllamaChatRequest request) {
    final url = '$baseUrl/chat';
    final controller = StreamController<OllamaChatResponse>();
    final httpRequest = http.Request('POST', Uri.parse(url))..headers.addAll(_buildHeaders())..body = json.encode(request.toJson()..['stream'] = true);
    _httpClient.send(httpRequest).then((streamedResponse) {
      streamedResponse.stream.transform(utf8.decoder).listen((data) {
        final lines = data.split('\n').where((s) => s.isNotEmpty);
        for (final line in lines) {
          try {
            controller.add(OllamaChatResponse.fromJson(json.decode(line)));
          } catch (e) {
            controller.addError(Exception('Error parsing stream chunk: $line'));
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
    final request = OllamaChatRequest(
      model: options['model'] ?? 'llama2',
      messages: messages,
    );
    final response = await _createChatInternal(request);
    return AiChatResponse(
      model: response.model,
      message: AiMessage.assistant(response.message.content),
    );
  }

  @override
  Stream<AiChatResponseChunk> createChatStream(List<AiMessage> messages, {Map<String, dynamic> options = const {}}) {
    final request = OllamaChatRequest(
      model: options['model'] ?? 'llama2',
      messages: messages,
      stream: true,
    );
    return _createChatStreamInternal(request).map((chunk) {
      return AiChatResponseChunk(
        model: chunk.model,
        content: chunk.message.content,
      );
    });
  }
}
