/// Response from the OpenAI audio transcription API.
class OpenAITranscriptionResponse {
  /// The transcribed text.
  final String text;

  OpenAITranscriptionResponse({required this.text});

  factory OpenAITranscriptionResponse.fromJson(Map<String, dynamic> json) {
    return OpenAITranscriptionResponse(
      text: json['text'],
    );
  }
}
