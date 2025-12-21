/// Represents a single embedding vector.
class AiEmbedding {
  /// The embedding vector, which is a list of floats.
  final List<double> values;

  const AiEmbedding(this.values);
}

/// Represents the output of an embedding request.
class AiEmbeddingResponse {
  /// The list of generated embeddings.
  final List<AiEmbedding> embeddings;

  const AiEmbeddingResponse(this.embeddings);
}

/// Represents a single generated image.
class AiImage {
  /// The URL or base64 encoded data of the generated image.
  final String data;

  const AiImage(this.data);
}

/// Represents the output of an image generation request.
class AiImageResponse {
  /// The list of generated images.
  final List<AiImage> images;

  const AiImageResponse(this.images);
}

/// Represents the output of an audio transcription or speech generation request.
class AiAudioResponse {
  /// The generated audio data (e.g., URL, file path, or bytes) or the
  /// transcribed text.
  final String data;

  const AiAudioResponse(this.data);
}
