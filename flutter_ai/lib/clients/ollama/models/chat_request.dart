import 'package:flutter_ai/core/models/ai_message.dart';

/// Represents the request payload for the Ollama Chat API.
class OllamaChatRequest {
  final String model;
  final List<AiMessage> messages;
  final bool stream;

  OllamaChatRequest({
    required this.model,
    required this.messages,
    this.stream = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages.map(_messageToJson).toList(),
      'stream': stream,
    };
  }

  Map<String, dynamic> _messageToJson(AiMessage message) {
    return {
      'role': message.role.name,
      'content': message.parts.whereType<AiTextContent>().map((p) => p.text).join('\n'),
    };
  }
}
