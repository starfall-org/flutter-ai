/// Response from the OpenAI video generation API.
class OpenAIVideoResponse {
  final int created;
  final List<VideoObject> data;

  OpenAIVideoResponse({
    required this.created,
    required this.data,
  });

  factory OpenAIVideoResponse.fromJson(Map<String, dynamic> json) {
    return OpenAIVideoResponse(
      created: json['created'],
      data: (json['data'] as List).map((e) => VideoObject.fromJson(e)).toList(),
    );
  }
}

class VideoObject {
  final String? url;
  final String? revisedPrompt;

  VideoObject({
    this.url,
    this.revisedPrompt,
  });

  factory VideoObject.fromJson(Map<String, dynamic> json) {
    return VideoObject(
      url: json['url'],
      revisedPrompt: json['revised_prompt'],
    );
  }
}
