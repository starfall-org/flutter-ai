import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/generate_content_request.dart';
import 'models/generate_content_response.dart';
import 'package:flutter_ai/core/ai_provider.dart';
import 'package:flutter_ai/core/models/ai_message.dart';
import 'package:flutter_ai/core/models/ai_response.dart';

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
    return '$baseUrl/models/$model:$task';
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
      streamedResponse.stream.transform(utf8.decoder).listen((data) {
        try {
          final cleanedData = data.trim().replaceAll('[', '').replaceAll(']', '');
          final parts = cleanedData.split('},').where((s) => s.isNotEmpty).toList();
          for (int i = 0; i < parts.length; i++) {
            var part = parts[i];
            if (i < parts.length - 1) {
              part += '}';
            }
            controller.add(GoogleAIGenerateContentResponse.fromJson(json.decode(part)));
          }
        } catch (e) {
          controller.addError(Exception('Error parsing stream chunk: $data'));
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
    final model = options['model'] ?? 'gemini-pro';
    final request = GoogleAIGenerateContentRequest(contents: messages);
    final response = await generateContent(model: model, request: request);
    final textContent = response.candidates.first.content.parts.map((p) => p.text).where((t) => t != null).join();
    return AiChatResponse(
      model: model,
      message: AiMessage.assistant(textContent),
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
}
