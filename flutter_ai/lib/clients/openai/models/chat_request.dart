import 'package:flutter_ai/core/models/ai_message.dart';
import 'package:flutter_ai/core/models/ai_tool.dart';

/// Represents the request payload for the OpenAI Chat Completions API.
class OpenAIChatRequest {
  final String model;
  final List<AiMessage> messages;
  final List<AiTool>? tools;
  final dynamic toolChoice;
  final bool stream;
  final double? temperature;
  final int? maxTokens;

  OpenAIChatRequest({
    required this.model,
    required this.messages,
    this.tools,
    this.toolChoice,
    this.stream = false,
    this.temperature,
    this.maxTokens,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages.map((m) => _messageToJson(m)).toList(),
      if (tools != null) 'tools': tools!.map((t) => _toolToJson(t)).toList(),
      if (toolChoice != null) 'tool_choice': toolChoice,
      'stream': stream,
      if (temperature != null) 'temperature': temperature,
      if (maxTokens != null) 'max_tokens': maxTokens,
    };
  }

  Map<String, dynamic> _messageToJson(AiMessage message) {
    return {
      'role': message.role.name,
      'content': message.parts.whereType<AiTextContent>().map((p) => p.text).join('\n'),
    };
  }

  Map<String, dynamic> _toolToJson(AiTool tool) {
    return {
      'type': 'function',
      'function': {
        'name': tool.name,
        'description': tool.description,
        'parameters': tool.parameters,
      },
    };
  }
}
