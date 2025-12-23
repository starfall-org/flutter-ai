import 'package:flutter_ai/core/models/ai_message.dart';

/// Represents the request payload for the Anthropic Messages API.
class AnthropicMessagesRequest {
  final String model;
  final List<AiMessage> messages;
  final String? system;
  final int maxTokens;
  final bool stream;
  final double? temperature;
  final List<Map<String, dynamic>>? tools;

  AnthropicMessagesRequest({
    required this.model,
    required this.messages,
    this.system,
    required this.maxTokens,
    this.stream = false,
    this.temperature,
    this.tools,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages.map(_messageToJson).toList(),
      if (system != null) 'system': system,
      'max_tokens': maxTokens,
      'stream': stream,
      if (temperature != null) 'temperature': temperature,
      if (tools != null) 'tools': tools,
    };
  }

  Map<String, dynamic> _messageToJson(AiMessage message) {
    final role = (message.role == AiMessageRole.assistant) ? 'assistant' : 'user';
    return {
      'role': role,
      'content': message.parts.map((p) {
        if (p is AiTextContent) {
          return {'type': 'text', 'text': p.text};
        }
        return {};
      }).toList(),
    };
  }
}
