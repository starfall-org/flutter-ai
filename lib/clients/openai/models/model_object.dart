/// Describes an OpenAI model offering that can be used with the API.
class OpenAIModel {
  /// The model identifier, which can be referenced in the API endpoints.
  final String id;

  /// The Unix timestamp (in seconds) when the model was created.
  final int created;

  /// The object type, which is always "model".
  final String object;

  /// The owner of the model, typically "openai" or "system".
  final String ownedBy;

  const OpenAIModel({
    required this.id,
    required this.created,
    required this.object,
    required this.ownedBy,
  });

  /// Creates an `OpenAIModel` instance from a JSON map.
  factory OpenAIModel.fromJson(Map<String, dynamic> json) {
    return OpenAIModel(
      id: json['id'],
      created: json['created'],
      object: json['object'],
      ownedBy: json['owned_by'],
    );
  }
}
