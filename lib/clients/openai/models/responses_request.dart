import 'package:flutter_ai/core/models/ai_message.dart';
import 'package:flutter_ai/core/models/ai_tool.dart';

/// Represents the request payload for the OpenAI Responses API.
class OpenAIResponsesRequest {
  final String model;
  final List<AiMessage> messages;
  final List<AiTool>? tools;
  final dynamic toolChoice;
  final bool stream;
  final double? temperature;
  final int? maxTokens;

  OpenAIResponsesRequest({
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
      'messages': messages.map((m) => {
        'role': m.role.name,
        'content': m.parts.whereType<AiTextContent>().map((p) => p.text).join(),
      }).toList(),
      if (tools != null) 'tools': tools!.map((t) => {
        'type': 'function',
        'function': {
          'name': t.name,
          'description': t.description,
          'parameters': t.parameters,
        },
      }).toList(),
      if (toolChoice != null) 'tool_choice': toolChoice,
      'stream': stream,
      if (temperature != null) 'temperature': temperature,
      if (maxTokens != null) 'max_tokens': maxTokens,
    };
  }
}
