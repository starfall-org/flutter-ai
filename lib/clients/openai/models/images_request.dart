
class OpenAIImagesRequest {
  final String prompt;
  final String? model;
  final int? n;
  final String? quality;
  final String? responseFormat;
  final String? size;
  final String? style;
  final String? user;

  OpenAIImagesRequest({
    required this.prompt,
    this.model,
    this.n,
    this.quality,
    this.responseFormat,
    this.size,
    this.style,
    this.user,
  });

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      if (model != null) 'model': model,
      if (n != null) 'n': n,
      if (quality != null) 'quality': quality,
      if (responseFormat != null) 'response_format': responseFormat,
      if (size != null) 'size': size,
      if (style != null) 'style': style,
      if (user != null) 'user': user,
    };
  }
}
