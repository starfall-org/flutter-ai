
import 'dart:async';
import 'dart:convert';
import 'package:flutter_ai/core/models/ai_request.dart';
import 'package:http/http.dart' as http;
import 'models/generate_content_request.dart';
import 'models/generate_content_response.dart';
import 'models/list_models_response.dart';
import 'package:flutter_ai/core/ai_provider.dart';
import 'package:flutter_ai/core/models/ai_message.dart';
import 'package:flutter_ai/core/models/ai_other_responses.dart';
import 'package:flutter_ai/core/models/ai_response.dart';
import 'package:flutter_ai/core/models/ai_tool.dart';
import 'package:flutter_ai/core/models/model_object.dart' as common;
import 'package:flutter_ai/core/models/tool.dart';

/// A client for interacting with the Google AI (Gemini) API.
class GoogleAIClient implements AiProvider {
  @override
  String get providerId => 'google';

  final String? apiKey;
  final String baseUrl;
  final Map<String, String>? headers;
  final http.Client _httpClient;

  GoogleAIClient({
    this.apiKey,
    this.baseUrl = 'https://generativelanguage.googleapis.com/v1beta',
    this.headers,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Map<String, String> _buildHeaders() {
    final finalHeaders = <String, String>{'Content-Type': 'application/json; charset=utf-8'};
    if (apiKey != null) {
      finalHeaders['x-goog-api-key'] = apiKey!;
    }
    if (headers != null) {
      finalHeaders.addAll(headers!);
    }
    return finalHeaders;
  }

  String _buildUrl(String model, String task) {
     if (model.startsWith('models/')) {
      return '$baseUrl/$model:$task';
    }
    return '$baseUrl/models/$model:$task';
  }

  @override
  Future<AiModelsResponse> getModels() async {
    final url = '$baseUrl/models';
    final response = await _httpClient.get(Uri.parse(url), headers: _buildHeaders());
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final models = (data['models'] as List).map((m) => GoogleAIModel.fromJson(m)).toList();
      final aiModels = models.map((m) => common.AiModel(id: m.name, created: 0, ownedBy: 'google')).toList();
      return AiModelsResponse(aiModels);
    } else {
      throw Exception('Failed to load models: ${response.statusCode} ${response.body}');
    }
  }

  Future<GoogleAIGenerateContentResponse> generateContent({required String model, required GoogleAIGenerateContentRequest request}) async {
    final url = _buildUrl(model, 'generateContent');
    final response = await _httpClient.post(Uri.parse(url), headers: _buildHeaders(), body: json.encode(request.toJson()));
    if (response.statusCode == 200) {
      return GoogleAIGenerateContentResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to generate content: ${response.statusCode} ${response.body}');
    }
  }

  Stream<GoogleAIGenerateContentResponse> generateContentStream({required String model, required GoogleAIGenerateContentRequest request}) {
    final url = _buildUrl(model, 'streamGenerateContent');
    final controller = StreamController<GoogleAIGenerateContentResponse>();
    final httpRequest = http.Request('POST', Uri.parse(url))..headers.addAll(_buildHeaders())..body = json.encode(request.toJson());
    _httpClient.send(httpRequest).then((streamedResponse) {
      String buffer = '';
      streamedResponse.stream.transform(utf8.decoder).listen((data) {
        buffer += data;
        // This regex looks for a complete JSON object.
        final regex = RegExp(r'\{.*?\}', dotAll: true);
        final matches = regex.allMatches(buffer);

        int offset = 0;
        for (final match in matches) {
          final jsonString = match.group(0);
          if (jsonString != null) {
            try {
              controller.add(GoogleAIGenerateContentResponse.fromJson(json.decode(jsonString)));
              offset = match.end;
            } catch (e) {
              // In case of an incomplete JSON object, we wait for more data.
            }
          }
        }
        buffer = buffer.substring(offset);

      }, onError: controller.addError, onDone: controller.close);
    }).catchError(controller.addError);
    return controller.stream;
  }

  void close() {
    _httpClient.close();
  }

  @override
  Future<AiChatResponse> createChat(List<AiMessage> messages, {Map<String, dynamic> options = const {}}) async {
    final model = options['model'] ?? 'gemini-pro';
    final tools = options['tools'] as List<AiTool>?;

    final request = GoogleAIGenerateContentRequest(
      contents: messages,
      tools: tools?.map((t) => t.toJson()).toList(),
    );
    final response = await generateContent(model: model, request: request);

    final parts = <AiContentPart>[];
    final textContent = response.candidates.first.content.parts.where((p) => p.text != null).map((p) => p.text).join();
    if (textContent.isNotEmpty) {
      parts.add(AiTextContent(textContent));
    }

    final toolCalls = response.candidates.first.content.parts
        .where((p) => p.functionCall != null)
        .map((p) => AiToolCall(
              id: p.functionCall!['name'],
              name: p.functionCall!['name'],
              arguments: jsonEncode(p.functionCall!['args']),
            ))
        .toList();

    if (toolCalls.isNotEmpty) {
      parts.add(AiToolCallContent(toolCalls));
    }

    return AiChatResponse(
      model: model,
      message: AiMessage(role: AiMessageRole.assistant, parts: parts),
    );
  }

  @override
  Stream<AiChatResponseChunk> createChatStream(List<AiMessage> messages, {Map<String, dynamic> options = const {}}) {
    final model = options['model'] ?? 'gemini-pro';
    final request = GoogleAIGenerateContentRequest(contents: messages);
    return generateContentStream(model: model, request: request).map((chunk) {
      final textContent = chunk.candidates.first.content.parts.map((p) => p.text).where((t) => t != null).join();
      return AiChatResponseChunk(
        model: model,
        content: textContent,
      );
    });
  }

  @override
  Future<AiEmbeddingResponse> getEmbeddings(AiEmbeddingRequest request) {
    throw UnsupportedError('Google AI does not support embeddings via this client.');
  }

  @override
  Future<AiImageResponse> createImage(AiImageRequest request) {
    throw UnsupportedError('Google AI does not support image generation via this client.');
  }

  @override
  Future<AiVideoResponse> createVideo(AiVideoRequest request) {
    throw UnsupportedError('Google AI does not support video generation via this client.');
  }

  @override
  Future<AiSpeechResponse> createSpeech(AiSpeechRequest request) {
    throw UnsupportedError('Google AI does not support speech generation via this client.');
  }

  @override
  Future<AiTranscriptionResponse> createTranscription(AiTranscriptionRequest request) {
    throw UnsupportedError('Google AI does not support transcription via this client.');
  }

  @override
  Future<AiImageResponse> editImage(AiImageEditRequest request) {
    throw UnsupportedError('Google AI does not support image editing via this client.');
  }
}
