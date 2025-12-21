// ignore_for_file: unused_element

/// Represents the role of the entity creating the message.
enum AiMessageRole {
  /// A system message that sets the context or instructions for the model.
  system,

  /// The user sending the request.
  user,

  /// The AI model responding.
  assistant,

  /// A tool that the model can call.
  tool,
}

/// A base class for different parts of content in a message.
///
/// This allows for multimodal input, where a single message can contain
/// text, images, videos, etc.
abstract class AiContentPart {
  const AiContentPart();
}

/// A content part that contains plain text.
class AiTextContent extends AiContentPart {
  /// The text content.
  final String text;

  const AiTextContent(this.text);
}

/// A content part that contains image data.
class AiImageContent extends AiContentPart {
  /// The image data, which can be a URL or base64 encoded string.
  final String data;

  const AiImageContent(this.data);
}

/// A content part that contains video data.
class AiVideoContent extends AiContentPart {
  /// The video data, typically a URL or file path.
  final String data;

  const AiVideoContent(this.data);
}

/// Represents a single message in a conversation with an AI model.
///
/// A message consists of a [role] and a list of content [parts],
/// allowing for rich, multimodal conversations.
class AiMessage {
  /// The role of the entity creating the message.
  final AiMessageRole role;

  /// The list of content parts that make up the message.
  final List<AiContentPart> parts;

  const AiMessage({
    required this.role,
    required this.parts,
  });

  /// A convenience constructor for creating a simple text message from the system.
  factory AiMessage.system(String text) {
    return AiMessage(
      role: AiMessageRole.system,
      parts: [AiTextContent(text)],
    );
  }

  /// A convenience constructor for creating a simple text message from the user.
  factory AiMessage.user(String text) {
    return AiMessage(
      role: AiMessageRole.user,
      parts: [AiTextContent(text)],
    );
  }

  /// A convenience constructor for creating a simple text message from the assistant.
  factory AiMessage.assistant(String text) {
    return AiMessage(
      role: AiMessageRole.assistant,
      parts: [AiTextContent(text)],
    );
  }
}
