import 'core/ai_provider.dart';
import 'core/models/ai_message.dart';
import 'core/models/ai_response.dart';

/// The main entry point for the Flutter AI package.
class FlutterAiClient {
  /// The underlying AI provider that this client delegates to.
  final AiProvider provider;

  /// Creates a new Flutter AI client with the specified [provider].
  FlutterAiClient({required this.provider});

  /// Creates a chat completion using the configured provider.
  Future<AiChatResponse> chat(
    List<AiMessage> messages, {
    Map<String, dynamic> options = const {},
  }) {
    return provider.createChat(messages, options: options);
  }

  /// Creates a streamed chat completion using the configured provider.
  Stream<AiChatResponseChunk> chatStream(
    List<AiMessage> messages, {
    Map<String, dynamic> options = const {},
  }) {
    return provider.createChatStream(messages, options: options);
  }
}
