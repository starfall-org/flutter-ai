/// Request for the OpenAI image edit API.
class OpenAIImageEditRequest {
  /// The image to edit.
  final List<int> image;

  /// The filename of the image.
  final String filename;

  /// A text description of the desired edit.
  final String prompt;

  /// The model to use for the edit.
  final String? model;

  OpenAIImageEditRequest({
    required this.image,
    required this.filename,
    required this.prompt,
    this.model,
  });
}
