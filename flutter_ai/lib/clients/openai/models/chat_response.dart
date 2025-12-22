/// Represents a choice in the chat completion response.
class OpenAIChatChoice {
  final int index;
  final Map<String, dynamic> message;
  final String? finishReason;

  OpenAIChatChoice({required this.index, required this.message, this.finishReason});

  factory OpenAIChatChoice.fromJson(Map<String, dynamic> json) {
    return OpenAIChatChoice(index: json['index'], message: json['message'], finishReason: json['finish_reason']);
  }

  /// Helper to get reasoning content from the message.
  String? get reasoningContent => message['reasoning_content'];
}

/// Represents the full response from the OpenAI Chat Completions API.
class OpenAIChatResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<OpenAIChatChoice> choices;

  OpenAIChatResponse({required this.id, required this.object, required this.created, required this.model, required this.choices});

  factory OpenAIChatResponse.fromJson(Map<String, dynamic> json) {
    return OpenAIChatResponse(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      model: json['model'],
      choices: (json['choices'] as List).map((c) => OpenAIChatChoice.fromJson(c)).toList(),
    );
  }
}

/// Represents a chunk of a streamed chat completion response.
class OpenAIChatStreamChunk {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<OpenAIChatStreamChoice> choices;

  OpenAIChatStreamChunk({required this.id, required this.object, required this.created, required this.model, required this.choices});

  factory OpenAIChatStreamChunk.fromJson(Map<String, dynamic> json) {
    return OpenAIChatStreamChunk(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      model: json['model'],
      choices: (json['choices'] as List).map((c) => OpenAIChatStreamChoice.fromJson(c)).toList(),
    );
  }
}

/// Represents a choice within a streamed chunk.
class OpenAIChatStreamChoice {
  final int index;
  final Map<String, dynamic> delta;
  final String? finishReason;

  OpenAIChatStreamChoice({required this.index, required this.delta, this.finishReason});

  factory OpenAIChatStreamChoice.fromJson(Map<String, dynamic> json) {
    return OpenAIChatStreamChoice(index: json['index'], delta: json['delta'], finishReason: json['finish_reason']);
  }

  /// Helper to get reasoning content from the delta.
  String? get reasoningContent => delta['reasoning_content'];
}
