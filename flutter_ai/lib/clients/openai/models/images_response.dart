
class OpenAIImagesResponse {
  final int created;
  final List<ImageObject> data;

  OpenAIImagesResponse({
    required this.created,
    required this.data,
  });

  factory OpenAIImagesResponse.fromJson(Map<String, dynamic> json) {
    return OpenAIImagesResponse(
      created: json['created'],
      data: (json['data'] as List).map((e) => ImageObject.fromJson(e)).toList(),
    );
  }
}

class ImageObject {
  final String? b64Json;
  final String? url;
  final String? revisedPrompt;

  ImageObject({
    this.b64Json,
    this.url,
    this.revisedPrompt,
  });

  factory ImageObject.fromJson(Map<String, dynamic> json) {
    return ImageObject(
      b64Json: json['b64_json'],
      url: json['url'],
      revisedPrompt: json['revised_prompt'],
    );
  }
}
