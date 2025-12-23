
class AiTool {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;

  AiTool({
    required this.name,
    required this.description,
    required this.parameters,
  });

  factory AiTool.fromJson(Map<String, dynamic> json) {
    return AiTool(
      name: json['name'],
      description: json['description'],
      parameters: json['parameters'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'parameters': parameters,
    };
  }
}
