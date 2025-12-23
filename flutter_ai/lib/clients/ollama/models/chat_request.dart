import 'package:flutter_ai/core/models/ai_message.dart';

/// Represents the request payload for the Ollama Chat API.
class OllamaChatRequest {
  final String model;
  final List<AiMessage> messages;
  final bool stream;
  final List<Map<String, dynamic>>? tools;

  OllamaChatRequest({
    required this.model,
    required this.messages,
    this.stream = false,
    this.tools,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages.map(_messageToJson).toList(),
      'stream': stream,
      if (tools != null) 'tools': tools,
    };
  }

  Map<String, dynamic> _messageToJson(AiMessage message) {
    return {
      'role': message.role.name,
      'content': message.parts.whereType<AiTextContent>().map((p) => p.text).join('\n'),
    };
  }
}
