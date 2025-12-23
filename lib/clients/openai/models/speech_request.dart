/// Request for the OpenAI speech generation API.
class OpenAISpeechRequest {
  /// The model to use for speech generation.
  final String model;

  /// The text to synthesize into speech.
  final String input;

  /// The voice to use for the speech.
  final String voice;

  /// The response format for the audio.
  final String? responseFormat;

  /// The speed of the speech.
  final double? speed;

  OpenAISpeechRequest({
    required this.model,
    required this.input,
    required this.voice,
    this.responseFormat,
    this.speed,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'input': input,
      'voice': voice,
      if (responseFormat != null) 'response_format': responseFormat,
      if (speed != null) 'speed': speed,
    };
  }
}
