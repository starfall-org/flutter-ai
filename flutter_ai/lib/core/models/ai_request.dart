/// A unified request for creating embeddings.
class AiEmbeddingRequest {
  /// The model to use for generating embeddings.
  final String model;

  /// The input text or texts to embed.
  final List<String> input;

  const AiEmbeddingRequest({
    required this.model,
    required this.input,
  });
}

/// A unified request for creating an image.
class AiImageRequest {
  /// The model to use for generating the image (e.g., 'dall-e-3').
  final String model;

  /// A text description of the desired image.
  final String prompt;

  /// The number of images to generate. Must be between 1 and 10.
  final int? n;

  /// The size of the generated images.
  final String? size;

  const AiImageRequest({
    required this.model,
    required this.prompt,
    this.n,
    this.size,
  });
}

/// A unified request for creating a video.
class AiVideoRequest {
  /// The model to use for generating the video.
  final String model;

  /// A text description of the desired video.
  final String prompt;

  const AiVideoRequest({
    required this.model,
    required this.prompt,
  });
}

/// A unified request for creating speech.
class AiSpeechRequest {
  /// The model to use for generating speech.
  final String model;

  /// The text to synthesize.
  final String input;

  /// The voice to use.
  final String voice;

  const AiSpeechRequest({
    required this.model,
    required this.input,
    required this.voice,
  });
}

/// A unified request for creating a transcription.
class AiTranscriptionRequest {
  /// The model to use for transcription.
  final String model;

  /// The audio file to transcribe.
  final List<int> file;

  /// The filename of the audio file.
  final String filename;

  const AiTranscriptionRequest({
    required this.model,
    required this.file,
    required this.filename,
  });
}

/// A unified request for editing an image.
class AiImageEditRequest {
  /// The image to edit.
  final List<int> image;

  /// The filename of the image.
  final String filename;

  /// A text description of the desired edit.
  final String prompt;

  /// The model to use for the edit.
  final String? model;

  const AiImageEditRequest({
    required this.image,
    required this.filename,
    required this.prompt,
    this.model,
  });
}
