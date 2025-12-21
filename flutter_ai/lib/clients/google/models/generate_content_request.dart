import 'package:flutter_ai/core/models/ai_message.dart';

/// Represents the request payload for the Google AI generateContent API.
class GoogleAIGenerateContentRequest {
  final List<AiMessage> contents;

  GoogleAIGenerateContentRequest({required this.contents});

  Map<String, dynamic> toJson() {
    return {
      'contents': contents.map(_contentToJson).toList(),
    };
  }

  Map<String, dynamic> _contentToJson(AiMessage message) {
    final role = (message.role == AiMessageRole.assistant) ? 'model' : 'user';
    return {
      'role': role,
      'parts': message.parts.map((p) {
        if (p is AiTextContent) {
          return {'text': p.text};
        } else if (p is AiImageContent) {
          return {
            'inline_data': {'mime_type': 'image/jpeg', 'data': p.data}
          };
        }
        return {};
      }).toList(),
    };
  }
}
