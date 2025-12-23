
import 'dart:async';
import 'dart:convert';
import 'package:flutter_ai/core/models/ai_request.dart';
import 'package:http/http.dart' as http;
import 'models/chat_request.dart';
import 'models/chat_response.dart';
import 'models/list_models_response.dart';
import 'package:flutter_ai/core/ai_provider.dart';
import 'package:flutter_ai/core/models/ai_message.dart';
import 'package:flutter_ai/core/models/ai_other_responses.dart';
import 'package:flutter_ai/core/models/ai_response.dart';
import 'package:flutter_ai/core/models/ai_tool.dart';
import 'package:flutter_ai/core/models/model_object.dart' as common;
import 'package:flutter_ai/core/models/tool.dart';

/// A client for interacting with the Ollama API.
class OllamaClient implements AiProvider {
  @override
  String get providerId => 'ollama';

  final String baseUrl;
  final Map<String, String>? headers;
  final http.Client _httpClient;

  OllamaClient({
    // Note: This default URL is per the user's specific request.
    // Most users will want to override this with their local Ollama address
    // (e.g., 'http://localhost:11434/api').
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

  @override
  Future<AiModelsResponse> getModels() async {
    final url = '$baseUrl/tags';
    final response = await _httpClient.get(Uri.parse(url), headers: _buildHeaders());
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final models = (data['models'] as List).map((m) => OllamaModel.fromJson(m)).toList();
      final aiModels = models.map((m) => common.AiModel(id: m.name, created: DateTime.parse(m.modifiedAt).millisecondsSinceEpoch, ownedBy: 'ollama')).toList();
      return AiModelsResponse(aiModels);
    } else {
      throw Exception('Failed to load models: ${response.statusCode} ${response.body}');
    }
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
    final tools = options['tools'] as List<AiTool>?;

    final request = OllamaChatRequest(
      model: options['model'] ?? 'llama2',
      messages: messages,
      tools: tools?.map((t) => t.toJson()).toList(),
    );
    final response = await _createChatInternal(request);

    final parts = <AiContentPart>[];
    if (response.message.content.isNotEmpty) {
      parts.add(AiTextContent(response.message.content));
    }

    final toolCalls = (response.message.toolCalls ?? [])
        .map((tc) => AiToolCall(
              id: tc['function']['name'],
              name: tc['function']['name'],
              arguments: jsonEncode(tc['function']['arguments']),
            ))
        .toList();

    if (toolCalls.isNotEmpty) {
      parts.add(AiToolCallContent(toolCalls));
    }

    return AiChatResponse(
      model: response.model,
      message: AiMessage(role: AiMessageRole.assistant, parts: parts),
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

  @override
  Future<AiEmbeddingResponse> getEmbeddings(AiEmbeddingRequest request) {
    throw UnsupportedError('Ollama does not support embeddings via this client.');
  }

  @override
  Future<AiImageResponse> createImage(AiImageRequest request) {
    throw UnsupportedError('Ollama does not support image generation.');
  }

  @override
  Future<AiVideoResponse> createVideo(AiVideoRequest request) {
    throw UnsupportedError('Ollama does not support video generation.');
  }

  @override
  Future<AiSpeechResponse> createSpeech(AiSpeechRequest request) {
    throw UnsupportedError('Ollama does not support speech generation.');
  }

  @override
  Future<AiTranscriptionResponse> createTranscription(AiTranscriptionRequest request) {
    throw UnsupportedError('Ollama does not support transcription.');
  }

  @override
  Future<AiImageResponse> editImage(AiImageEditRequest request) {
    throw UnsupportedError('Ollama does not support image editing.');
  }
}
