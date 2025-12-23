
class OllamaListModelsResponse {
  final List<OllamaModel> models;

  OllamaListModelsResponse({required this.models});

  factory OllamaListModelsResponse.fromJson(Map<String, dynamic> json) {
    return OllamaListModelsResponse(
      models: (json['models'] as List).map((e) => OllamaModel.fromJson(e)).toList(),
    );
  }
}

class OllamaModel {
  final String name;
  final String modifiedAt;
  final int size;

  OllamaModel({
    required this.name,
    required this.modifiedAt,
    required this.size,
  });

  factory OllamaModel.fromJson(Map<String, dynamic> json) {
    return OllamaModel(
      name: json['name'],
      modifiedAt: json['modified_at'],
      size: json['size'],
    );
  }
}
