/// Represents the full response from the Google AI generateContent API.
class GoogleAIGenerateContentResponse {
  final List<GoogleAICandidate> candidates;

  GoogleAIGenerateContentResponse({required this.candidates});

  factory GoogleAIGenerateContentResponse.fromJson(Map<String, dynamic> json) {
    return GoogleAIGenerateContentResponse(
      candidates: (json['candidates'] as List).map((c) => GoogleAICandidate.fromJson(c)).toList(),
    );
  }
}

class GoogleAICandidate {
  final GoogleAIContent content;
  GoogleAICandidate({required this.content});
  factory GoogleAICandidate.fromJson(Map<String, dynamic> json) {
    return GoogleAICandidate(content: GoogleAIContent.fromJson(json['content']));
  }
}

class GoogleAIContent {
  final String role;
  final List<GoogleAIPart> parts;
  GoogleAIContent({required this.role, required this.parts});
  factory GoogleAIContent.fromJson(Map<String, dynamic> json) {
    return GoogleAIContent(
      role: json['role'],
      parts: (json['parts'] as List).map((p) => GoogleAIPart.fromJson(p)).toList(),
    );
  }
}

class GoogleAIPart {
  final String? text;
  final Map<String, dynamic>? functionCall;
  GoogleAIPart({this.text, this.functionCall});
  factory GoogleAIPart.fromJson(Map<String, dynamic> json) {
    return GoogleAIPart(
      text: json['text'],
      functionCall: json['functionCall'],
    );
  }
}
