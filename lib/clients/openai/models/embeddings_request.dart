
class OpenAIEmbeddingsRequest {
  final String model;
  final dynamic input; // Can be String or List<String>
  final String? encodingFormat;
  final int? dimensions;
  final String? user;

  OpenAIEmbeddingsRequest({
    required this.model,
    required this.input,
    this.encodingFormat,
    this.dimensions,
    this.user,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'input': input,
      if (encodingFormat != null) 'encoding_format': encodingFormat,
      if (dimensions != null) 'dimensions': dimensions,
      if (user != null) 'user': user,
    };
  }
}
