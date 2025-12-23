/// Request for the OpenAI video generation API.
class OpenAIVideoRequest {
  /// The model to use for video generation.
  final String model;

  /// The text prompt for the video.
  final String prompt;

  OpenAIVideoRequest({
    required this.model,
    required this.prompt,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'prompt': prompt,
    };
  }
}
