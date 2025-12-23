
/// A standardized representation of an AI model.
class AiModel {
  final String id;
  final int created;
  final String ownedBy;

  AiModel({
    required this.id,
    required this.created,
    required this.ownedBy,
  });

  factory AiModel.fromJson(Map<String, dynamic> json) {
    return AiModel(
      id: json['id'],
      created: json['created'],
      ownedBy: json['owned_by'],
    );
  }
}
