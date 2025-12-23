import 'package:flutter_ai/core/models/ai_message.dart';

/// Represents the request payload for the Google AI generateContent API.
class GoogleAIGenerateContentRequest {
  final List<AiMessage> contents;
  final List<Map<String, dynamic>>? tools;

  GoogleAIGenerateContentRequest({required this.contents, this.tools});

  Map<String, dynamic> toJson() {
    return {
      'contents': contents.map(_contentToJson).toList(),
      if (tools != null) 'tools': tools,
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
        } else if (p is AiVideoContent) {
          return {
            'inline_data': {'mime_type': 'video/mp4', 'data': p.data}
          };
        }
        return {};
      }).toList(),
    };
  }
}
