/// Represents the response from the Ollama Chat API.
class OllamaChatResponse {
  final String model;
  final DateTime createdAt;
  final OllamaMessage message;
  final bool done;

  OllamaChatResponse({required this.model, required this.createdAt, required this.message, required this.done});

  factory OllamaChatResponse.fromJson(Map<String, dynamic> json) {
    return OllamaChatResponse(
      model: json['model'],
      createdAt: DateTime.parse(json['created_at']),
      message: OllamaMessage.fromJson(json['message']),
      done: json['done'],
    );
  }
}

class OllamaMessage {
  final String role;
  final String content;

  OllamaMessage({required this.role, required this.content});

  factory OllamaMessage.fromJson(Map<String, dynamic> json) {
    return OllamaMessage(role: json['role'], content: json['content']);
  }
}
