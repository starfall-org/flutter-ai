/// Represents the full response from the Anthropic Messages API.
class AnthropicMessagesResponse {
  final String id;
  final String type;
  final String role;
  final String model;
  final List<Map<String, dynamic>> content;
  final String? stopReason;

  AnthropicMessagesResponse({
    required this.id,
    required this.type,
    required this.role,
    required this.model,
    required this.content,
    this.stopReason,
  });

  factory AnthropicMessagesResponse.fromJson(Map<String, dynamic> json) {
    return AnthropicMessagesResponse(
      id: json['id'],
      type: json['type'],
      role: json['role'],
      model: json['model'],
      content: List<Map<String, dynamic>>.from(json['content']),
      stopReason: json['stop_reason'],
    );
  }
}

/// Represents a chunk (event) from the streamed Anthropic Messages API.
class AnthropicMessagesStreamEvent {
  final String type;
  final Map<String, dynamic> data;

  AnthropicMessagesStreamEvent({required this.type, required this.data});

  String? get textDelta {
    if (type == 'content_block_delta' &&
        data['delta'] != null &&
        data['delta']['type'] == 'text_delta') {
      return data['delta']['text'];
    }
    return null;
  }
}
