
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_ai/core/models/ai_request.dart';
import 'package:http/http.dart' as http;
import 'models/model_object.dart';
import 'models/responses_request.dart';
import 'models/responses_response.dart';
import 'models/embeddings_request.dart';
import 'models/embeddings_response.dart';
import 'models/image_edit_request.dart';
import 'models/images_request.dart';
import 'models/images_response.dart';
import 'models/speech_request.dart';
import 'models/transcriptions_request.dart';
import 'models/transcriptions_response.dart';
import 'models/video_request.dart';
import 'models/video_response.dart';
import 'package:flutter_ai/core/ai_provider.dart';
import 'package:flutter_ai/core/models/ai_message.dart';
import 'package:flutter_ai/core/models/ai_other_responses.dart';
import 'package:flutter_ai/core/models/ai_response.dart';
import 'package:flutter_ai/core/models/ai_tool.dart';
import 'package:flutter_ai/core/models/model_object.dart' as common;
import 'package:flutter_ai/core/models/tool.dart';

/// A client for interacting with the OpenAI API.
class OpenAIClient implements AiProvider {
  @override
  String get providerId => 'openai';

  final String? apiKey;
  final String baseUrl;
  final Map<String, String>? headers;
  final http.Client _httpClient;

  OpenAIClient({
    this.apiKey,
    this.baseUrl = 'https://api.openai.com/v1',
    this.headers,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Map<String, String> _buildHeaders({bool isMultipart = false}) {
    final finalHeaders = <String, String>{};
    if (!isMultipart) {
      finalHeaders['Content-Type'] = 'application/json; charset=utf-8';
    }
    if (apiKey != null) {
      finalHeaders['Authorization'] = 'Bearer $apiKey';
    }
    if (headers != null) {
      finalHeaders.addAll(headers!);
    }
    return finalHeaders;
  }

  @override
  Future<AiModelsResponse> getModels() async {
    final url = '$baseUrl/models';
    final response = await _httpClient.get(Uri.parse(url), headers: _buildHeaders());
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'] as List;
      final models = data.map((modelJson) {
        final openAiModel = OpenAIModel.fromJson(modelJson);
        return common.AiModel(id: openAiModel.id, created: openAiModel.created, ownedBy: openAiModel.ownedBy);
      }).toList();
      return AiModelsResponse(models);
    } else {
      throw Exception('Failed to load models: ${response.statusCode} ${response.body}');
    }
  }

  // --- Chat ---
  Future<OpenAIResponsesResponse> _createResponse(OpenAIResponsesRequest request) async {
    final url = '$baseUrl/responses';
    final response = await _httpClient.post(Uri.parse(url), headers: _buildHeaders(), body: json.encode(request.toJson()));
    if (response.statusCode == 200) {
      return OpenAIResponsesResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create response: ${response.statusCode} ${response.body}');
    }
  }

  Stream<OpenAIResponsesStreamChunk> _createResponseStream(OpenAIResponsesRequest request) {
    final url = '$baseUrl/responses';
    final controller = StreamController<OpenAIResponsesStreamChunk>();
    final httpRequest = http.Request('POST', Uri.parse(url))..headers.addAll(_buildHeaders())..body = json.encode(request.toJson()..['stream'] = true);
    _httpClient.send(httpRequest).then((streamedResponse) {
      streamedResponse.stream.transform(utf8.decoder).listen((data) {
        final lines = data.split('\n').where((line) => line.trim().startsWith('data: '));
        for (final line in lines) {
          final jsonString = line.substring(6).trim();
          if (jsonString == '[DONE]') {
            controller.close();
            return;
          }
          try {
            controller.add(OpenAIResponsesStreamChunk.fromJson(json.decode(jsonString)));
          } catch (e) {
            controller.addError(Exception('Error parsing stream chunk: $jsonString'));
          }
        }
      }, onError: controller.addError, onDone: controller.close);
    }).catchError(controller.addError);
    return controller.stream;
  }

  // --- Embeddings ---
  Future<OpenAIEmbeddingsResponse> _createEmbeddings(OpenAIEmbeddingsRequest request) async {
    final url = '$baseUrl/embeddings';
    final response = await _httpClient.post(Uri.parse(url), headers: _buildHeaders(), body: json.encode(request.toJson()));
     if (response.statusCode == 200) {
      return OpenAIEmbeddingsResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create embeddings: ${response.statusCode} ${response.body}');
    }
  }

  // --- Images ---
  Future<OpenAIImagesResponse> _createImage(OpenAIImagesRequest request) async {
    final url = '$baseUrl/images/generations';
    final response = await _httpClient.post(Uri.parse(url), headers: _buildHeaders(), body: json.encode(request.toJson()));
    if (response.statusCode == 200) {
      return OpenAIImagesResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create image: ${response.statusCode} ${response.body}');
    }
  }

  Future<OpenAIImagesResponse> _editImage(OpenAIImageEditRequest request) async {
    final url = '$baseUrl/images/edits';
    final httpRequest = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(_buildHeaders(isMultipart: true))
      ..fields['prompt'] = request.prompt
      ..files.add(http.MultipartFile.fromBytes('image', request.image, filename: request.filename));

    if (request.model != null) httpRequest.fields['model'] = request.model!;

    final response = await _httpClient.send(httpRequest);
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return OpenAIImagesResponse.fromJson(json.decode(responseBody));
    } else {
      final errorBody = await response.stream.bytesToString();
      throw Exception('Failed to edit image: ${response.statusCode} $errorBody');
    }
  }

  // --- Audio ---
  Future<Uint8List> createSpeech(OpenAISpeechRequest request) async {
    final url = '$baseUrl/audio/speech';
    final response = await _httpClient.post(Uri.parse(url), headers: _buildHeaders(), body: json.encode(request.toJson()));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to create speech: ${response.statusCode} ${response.body}');
    }
  }

  Future<OpenAITranscriptionResponse> createTranscription(OpenAITranscriptionRequest request) async {
    final url = '$baseUrl/audio/transcriptions';
    final httpRequest = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(_buildHeaders(isMultipart: true))
      ..fields['model'] = request.model
      ..files.add(http.MultipartFile.fromBytes('file', request.file, filename: request.filename));

    if (request.language != null) httpRequest.fields['language'] = request.language!;
    if (request.prompt != null) httpRequest.fields['prompt'] = request.prompt!;
    if (request.responseFormat != null) httpRequest.fields['response_format'] = request.responseFormat!;
    if (request.temperature != null) httpRequest.fields['temperature'] = request.temperature!.toString();

    final response = await _httpClient.send(httpRequest);
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return OpenAITranscriptionResponse.fromJson(json.decode(responseBody));
    } else {
      final errorBody = await response.stream.bytesToString();
      throw Exception('Failed to create transcription: ${response.statusCode} $errorBody');
    }
  }

  // --- Video ---
  Future<OpenAIVideoResponse> _createVideo(OpenAIVideoRequest request) async {
    final url = '$baseUrl/videos';
    final response = await _httpClient.post(Uri.parse(url), headers: _buildHeaders(), body: json.encode(request.toJson()));
    if (response.statusCode == 200) {
      return OpenAIVideoResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create video: ${response.statusCode} ${response.body}');
    }
  }

  void close() {
    _httpClient.close();
  }

  @override
  Future<AiChatResponse> createChat(List<AiMessage> messages, {Map<String, dynamic> options = const {}}) async {
    final List<AiTool>? tools = options['tools'] as List<AiTool>?;

    final request = OpenAIResponsesRequest(
      model: options['model'] ?? 'gpt-3.5-turbo',
      messages: messages,
      temperature: options['temperature'],
      tools: tools,
      toolChoice: options['tool_choice'],
    );

    final response = await _createResponse(request);
    final choice = response.choices.first;
    final message = choice['message'];

    final List<AiContentPart> parts = [];
    if (message['content'] is String && (message['content'] as String).isNotEmpty) {
       parts.add(AiTextContent(message['content']));
    }
    final rawToolCalls = message['tool_calls'] as List?;
    if (rawToolCalls != null && rawToolCalls.isNotEmpty) {
      final toolCalls = rawToolCalls.map((tc) {
        return AiToolCall(
          id: tc['id'],
          name: tc['function']['name'],
          arguments: tc['function']['arguments'],
        );
      }).toList();
      parts.add(AiToolCallContent(toolCalls));
    }

    return AiChatResponse(
      id: response.id,
      model: response.model,
      message: AiMessage(
        role: AiMessageRole.assistant,
        parts: parts,
      ),
      reasoning: choice['logprobs'] != null ? jsonEncode(choice['logprobs']['content']) : null,
    );
  }

  @override
  Stream<AiChatResponseChunk> createChatStream(List<AiMessage> messages, {Map<String, dynamic> options = const {}}) {
    final request = OpenAIResponsesRequest(
      model: options['model'] ?? 'gpt-3.5-turbo',
      messages: messages,
      temperature: options['temperature'],
      stream: true,
    );
    return _createResponseStream(request).map((chunk) {
      final choice = chunk.choices.first;
      return AiChatResponseChunk(
        model: chunk.model,
        content: choice['delta']['content'],
        reasoning: choice['logprobs'] != null ? jsonEncode(choice['logprobs']['content']) : null,
      );
    });
  }

  @override
  Future<AiEmbeddingResponse> getEmbeddings(AiEmbeddingRequest request) async {
    final openAIRequest = OpenAIEmbeddingsRequest(
      model: request.model,
      input: request.input,
    );
    final response = await _createEmbeddings(openAIRequest);
    final embeddings = response.data.map((e) => AiEmbedding(e.embedding)).toList();
    return AiEmbeddingResponse(embeddings);
  }

  @override
  Future<AiImageResponse> createImage(AiImageRequest request) async {
    final openAIRequest = OpenAIImagesRequest(
      prompt: request.prompt,
      model: request.model,
      n: request.n,
      size: request.size,
    );
    final response = await _createImage(openAIRequest);
    final images = response.data.map((e) => AiImage(e.url ?? e.b64Json ?? '')).toList();
    return AiImageResponse(images);
  }

  @override
  Future<AiImageResponse> editImage(AiImageEditRequest request) async {
    final openAIRequest = OpenAIImageEditRequest(
      image: request.image,
      filename: request.filename,
      prompt: request.prompt,
      model: request.model,
    );
    final response = await _editImage(openAIRequest);
    final images = response.data.map((e) => AiImage(e.url ?? e.b64Json ?? '')).toList();
    return AiImageResponse(images);
  }

  @override
  Future<AiVideoResponse> createVideo(AiVideoRequest request) async {
    final openAIRequest = OpenAIVideoRequest(
      prompt: request.prompt,
      model: request.model,
    );
    final response = await _createVideo(openAIRequest);
    final videos = response.data.map((e) => AiVideo(e.url ?? '')).toList();
    return AiVideoResponse(videos);
  }
}
