import 'package:flutter_ai/core/models/ai_message.dart';
import 'package:flutter_ai/core/models/ai_other_responses.dart';
import 'package:flutter_ai/core/models/ai_request.dart';
import 'package:flutter_ai/core/models/ai_response.dart';
import 'package:flutter_ai/core/models/model_object.dart';

/// An abstract interface for AI providers.
abstract class AiProvider {
  /// A unique identifier for the provider.
  String get providerId;

  /// Lists the available models from the provider.
  Future<AiModelsResponse> getModels();

  /// Creates a chat completion.
  Future<AiChatResponse> createChat(List<AiMessage> messages, {Map<String, dynamic> options});

  /// Creates a streamed chat completion.
  Stream<AiChatResponseChunk> createChatStream(List<AiMessage> messages, {Map<String, dynamic> options});

  /// Creates embeddings for the given input.
  Future<AiEmbeddingResponse> getEmbeddings(AiEmbeddingRequest request);

  /// Creates an image based on a prompt.
  Future<AiImageResponse> createImage(AiImageRequest request);

  /// Creates a video based on a prompt.
  Future<AiVideoResponse> createVideo(AiVideoRequest request);

  /// Creates speech from text.
  Future<AiSpeechResponse> createSpeech(AiSpeechRequest request);

  /// Creates a transcription from audio.
  Future<AiTranscriptionResponse> createTranscription(AiTranscriptionRequest request);

  /// Edits an image based on a prompt.
  Future<AiImageResponse> editImage(AiImageEditRequest request);
}
