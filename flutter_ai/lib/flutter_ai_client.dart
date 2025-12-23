import 'package:flutter_ai/core/models/ai_other_responses.dart';
import 'package:flutter_ai/core/models/ai_request.dart';
import 'clients/anthropic/anthropic_client.dart';
import 'clients/google/google_ai_client.dart';
import 'clients/mcp_client.dart';
import 'clients/ollama/ollama_client.dart';
import 'clients/openai/openai_client.dart';
import 'core/ai_provider.dart';
import 'core/models/ai_message.dart';
import 'core/models/ai_response.dart';
import 'dart:io' show Platform;

/// The main entry point for the Flutter AI package.
///
/// This class provides a unified interface to interact with various AI providers.
/// Use the factory constructors to easily create a client for a specific provider.
class FlutterAiClient implements AiProvider {
  /// The underlying AI provider that this client delegates to.
  final AiProvider _provider;

  /// An optional client for interacting with an MCP server.
  final McpClient? mcpClient;

  /// Creates a new Flutter AI client with the specified [provider].
  FlutterAiClient({required AiProvider provider, this.mcpClient}) : _provider = provider;

  /// Creates a new OpenAI client.
  ///
  /// The API key is read from the `OPENAI_API_KEY` environment variable.
  factory FlutterAiClient.openai({String? apiKey, McpClient? mcpClient}) {
    return FlutterAiClient(
      provider: OpenAIClient(apiKey: apiKey ?? Platform.environment['OPENAI_API_KEY']),
      mcpClient: mcpClient,
    );
  }

  /// Creates a new Anthropic client.
  ///
  /// The API key is read from the `ANTHROPIC_API_KEY` environment variable.
  factory FlutterAiClient.anthropic({String? apiKey, McpClient? mcpClient}) {
    return FlutterAiClient(
      provider: AnthropicClient(apiKey: apiKey ?? Platform.environment['ANTHROPIC_API_KEY']),
      mcpClient: mcpClient,
    );
  }

  /// Creates a new Google AI (Gemini) client.
  ///
  /// The API key is read from the `GOOGLE_API_KEY` environment variable.
  factory FlutterAiClient.google({String? apiKey, McpClient? mcpClient}) {
    return FlutterAiClient(
      provider: GoogleAIClient(apiKey: apiKey ?? Platform.environment['GOOGLE_API_KEY']),
      mcpClient: mcpClient,
    );
  }

  /// Creates a new Ollama client.
  factory FlutterAiClient.ollama({McpClient? mcpClient}) {
    return FlutterAiClient(provider: OllamaClient(), mcpClient: mcpClient);
  }

  @override
  String get providerId => _provider.providerId;

  @override
  Future<AiModelsResponse> getModels() {
    return _provider.getModels();
  }

  @override
  Future<AiChatResponse> createChat(List<AiMessage> messages, {Map<String, dynamic> options = const {}}) {
    return _provider.createChat(messages, options: options);
  }

  @override
  Stream<AiChatResponseChunk> createChatStream(List<AiMessage> messages, {Map<String, dynamic> options = const {}}) {
    return _provider.createChatStream(messages, options: options);
  }

  @override
  Future<AiEmbeddingResponse> getEmbeddings(AiEmbeddingRequest request) {
    return _provider.getEmbeddings(request);
  }

  @override
  Future<AiImageResponse> createImage(AiImageRequest request) {
    return _provider.createImage(request);
  }

  @override
  Future<AiVideoResponse> createVideo(AiVideoRequest request) {
    return _provider.createVideo(request);
  }

  @override
  Future<AiSpeechResponse> createSpeech(AiSpeechRequest request) {
    return _provider.createSpeech(request);
  }

  @override
  Future<AiTranscriptionResponse> createTranscription(AiTranscriptionRequest request) {
    return _provider.createTranscription(request);
  }

  @override
  Future<AiImageResponse> editImage(AiImageEditRequest request) {
    return _provider.editImage(request);
  }
}
