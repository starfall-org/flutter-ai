import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/model_object.dart';
import 'models/chat_request.dart';
import 'models/chat_response.dart';
import 'models/responses_request.dart';
import 'models/responses_response.dart';
import 'package:flutter_ai/core/ai_provider.dart';
import 'package:flutter_ai/core/models/ai_message.dart';
import 'package:flutter_ai/core/models/ai_response.dart';
import 'package:flutter_ai/core/models/ai_tool.dart';

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

  Map<String, String> _buildHeaders() {
    final finalHeaders = <String, String>{'Content-Type': 'application/json; charset=utf-8'};
    if (apiKey != null) {
      finalHeaders['Authorization'] = 'Bearer $apiKey';
    }
    if (headers != null) {
      finalHeaders.addAll(headers!);
    }
    return finalHeaders;
  }

  Future<List<OpenAIModel>> getModels({String? listModelsUrl}) async {
    final url = listModelsUrl ?? '$baseUrl/models';
    final response = await _httpClient.get(Uri.parse(url), headers: _buildHeaders());
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes))['data'] as List;
      return data.map((modelJson) => OpenAIModel.fromJson(modelJson)).toList();
    } else {
      throw Exception('Failed to load models: ${response.statusCode} ${response.body}');
    }
  }

  Future<OpenAIChatResponse> createChatCompletion(OpenAIChatRequest request) async {
    final url = '$baseUrl/chat/completions';
    final response = await _httpClient.post(Uri.parse(url), headers: _buildHeaders(), body: json.encode(request.toJson()));
    if (response.statusCode == 200) {
      return OpenAIChatResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create chat completion: ${response.statusCode} ${response.body}');
    }
  }

  Stream<OpenAIChatStreamChunk> createChatCompletionStream(OpenAIChatRequest request) {
    final url = '$baseUrl/chat/completions';
    final controller = StreamController<OpenAIChatStreamChunk>();
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
            controller.add(OpenAIChatStreamChunk.fromJson(json.decode(jsonString)));
          } catch (e) {
            controller.addError(Exception('Error parsing stream chunk: $jsonString'));
          }
        }
      }, onError: controller.addError, onDone: controller.close);
    }).catchError(controller.addError);
    return controller.stream;
  }

  Future<OpenAIResponsesResponse> createResponses(OpenAIResponsesRequest request) async {
    final url = '$baseUrl/responses';
    final response = await _httpClient.post(Uri.parse(url), headers: _buildHeaders(), body: json.encode(request.toJson()));
    if (response.statusCode == 200) {
      return OpenAIResponsesResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create response: ${response.statusCode} ${response.body}');
    }
  }

  Stream<OpenAIResponsesStreamChunk> createResponsesStream(OpenAIResponsesRequest request) {
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

  void close() {
    _httpClient.close();
  }

  @override
  Future<AiChatResponse> createChat(List<AiMessage> messages, {Map<String, dynamic> options = const {}}) async {
    final request = OpenAIChatRequest(
      model: options['model'] ?? 'gpt-3.5-turbo',
      messages: messages,
      temperature: options['temperature'],
      tools: options['tools'] as List<AiTool>?,
      toolChoice: options['tool_choice'],
    );

    final response = await createChatCompletion(request);
    final choice = response.choices.first;
    final message = choice.message;

    // Check for tool calls in the response.
    if (message['tool_calls'] != null) {
      final toolCalls = (message['tool_calls'] as List).map((tc) {
        return AiToolCall(
          id: tc['id'],
          name: tc['function']['name'],
          arguments: json.decode(tc['function']['arguments']),
        );
      }).toList();

      return AiChatResponse(
        id: response.id,
        model: response.model,
        message: AiMessage(
          role: AiMessageRole.assistant,
          parts: [AiToolCallContent(toolCalls)],
        ),
        reasoning: choice.reasoningContent,
      );
    } else {
      // Default behavior: handle text content.
      return AiChatResponse(
        id: response.id,
        model: response.model,
        message: AiMessage.assistant(message['content'] ?? ''),
        reasoning: choice.reasoningContent,
      );
    }
  }

  @override
  Stream<AiChatResponseChunk> createChatStream(List<AiMessage> messages, {Map<String, dynamic> options = const {}}) {
    final request = OpenAIChatRequest(
      model: options['model'] ?? 'gpt-3.5-turbo',
      messages: messages,
      temperature: options['temperature'],
      stream: true,
    );
    return createChatCompletionStream(request).map((chunk) {
      final choice = chunk.choices.first;
      return AiChatResponseChunk(
        model: chunk.model,
        content: choice.delta['content'],
        reasoning: choice.reasoningContent,
      );
    });
  }
}
