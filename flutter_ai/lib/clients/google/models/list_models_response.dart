
class GoogleAIListModelsResponse {
  final List<GoogleAIModel> models;

  GoogleAIListModelsResponse({required this.models});

  factory GoogleAIListModelsResponse.fromJson(Map<String, dynamic> json) {
    return GoogleAIListModelsResponse(
      models: (json['models'] as List).map((e) => GoogleAIModel.fromJson(e)).toList(),
    );
  }
}

class GoogleAIModel {
  final String name;
  final String version;
  final String displayName;
  final String description;
  final int inputTokenLimit;
  final int outputTokenLimit;
  final List<String> supportedGenerationMethods;
  final double? temperature;
  final double? topP;
  final int? topK;

  GoogleAIModel({
    required this.name,
    required this.version,
    required this.displayName,
    required this.description,
    required this.inputTokenLimit,
    required this.outputTokenLimit,
    required this.supportedGenerationMethods,
    this.temperature,
    this.topP,
    this.topK,
  });

  factory GoogleAIModel.fromJson(Map<String, dynamic> json) {
    return GoogleAIModel(
      name: json['name'],
      version: json['version'],
      displayName: json['displayName'],
      description: json['description'],
      inputTokenLimit: json['inputTokenLimit'],
      outputTokenLimit: json['outputTokenLimit'],
      supportedGenerationMethods: (json['supportedGenerationMethods'] as List).cast<String>(),
      temperature: json['temperature']?.toDouble(),
      topP: json['topP']?.toDouble(),
      topK: json['topK'],
    );
  }
}
