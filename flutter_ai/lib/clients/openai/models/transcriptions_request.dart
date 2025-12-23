/// Request for the OpenAI audio transcription API.
class OpenAITranscriptionRequest {
  /// The audio file to transcribe, as a list of bytes.
  final List<int> file;

  /// The name of the file.
  final String filename;

  /// The model to use for transcription.
  final String model;

  /// The language of the audio data.
  final String? language;

  /// The prompt to guide the model's transcription.
  final String? prompt;

  /// The response format for the transcription.
  final String? responseFormat;

  /// The temperature for the transcription.
  final double? temperature;

  OpenAITranscriptionRequest({
    required this.file,
    required this.filename,
    required this.model,
    this.language,
    this.prompt,
    this.responseFormat,
    this.temperature,
  });
}
