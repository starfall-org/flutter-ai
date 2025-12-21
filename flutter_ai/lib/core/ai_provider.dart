import 'package:flutter_ai/core/models/ai_message.dart';
import 'package:flutter_ai/core/models/ai_response.dart';

/// An abstract interface for AI providers.
abstract class AiProvider {
  /// A unique identifier for the provider.
  String get providerId;

  /// Creates a chat completion.
  Future<AiChatResponse> createChat(List<AiMessage> messages, {Map<String, dynamic> options});

  /// Creates a streamed chat completion.
  Stream<AiChatResponseChunk> createChatStream(List<AiMessage> messages, {Map<String, dynamic> options});
}
