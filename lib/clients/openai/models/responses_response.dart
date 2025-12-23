/// Represents the response from the OpenAI Responses API.
class OpenAIResponsesResponse {
  final String id;
  final String model;
  final List<dynamic> choices;

  OpenAIResponsesResponse({required this.id, required this.model, required this.choices});

  factory OpenAIResponsesResponse.fromJson(Map<String, dynamic> json) {
    return OpenAIResponsesResponse(id: json['id'], model: json['model'], choices: json['choices']);
  }
}

/// Represents a chunk from the streamed OpenAI Responses API.
class OpenAIResponsesStreamChunk {
  final String id;
  final String model;
  final List<dynamic> choices;

  OpenAIResponsesStreamChunk({required this.id, required this.model, required this.choices});

  factory OpenAIResponsesStreamChunk.fromJson(Map<String, dynamic> json) {
    return OpenAIResponsesStreamChunk(id: json['id'], model: json['model'], choices: json['choices']);
  }
}
