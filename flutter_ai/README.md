# flutter_ai

A unified Dart package for interacting with various AI APIs.

This library provides a consistent and simple interface for accessing generative AI models from providers like OpenAI, Anthropic, Google AI, and Ollama. It offers a standardized data model and a unified client to abstract away the complexities of each individual API.

## Features

- **Unified Client**: A single client (`FlutterAiClient`) to interact with multiple AI providers.
- **Standardized Models**: Consistent request and response models (`AiMessage`, `AiChatResponse`, etc.).
- **Streaming Support**: Built-in support for streaming chat responses from all providers.
- **Provider-Specific Access**: Option to use individual clients (`OpenAIClient`, `AnthropicClient`, etc.) for provider-specific features.
- **MCP Integration**: Includes a client for discovering tools from MCP-compliant servers.

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_ai: ^0.0.1
```

Then, run `dart pub get` or `flutter pub get`.

## Usage

### 1. Unified Client with OpenAI (Test Server)

```dart
import 'package:flutter_ai/flutter_ai.dart';

void main() async {
  final openAiClient = OpenAIClient(
    baseUrl: 'https://oi-vscode-server-0501.onrender.com/v1',
    apiKey: 'no-key-needed',
  );
  final client = FlutterAiClient(provider: openAiClient);
  final messages = [
    AiMessage.system('You are a helpful assistant.'),
    AiMessage.user('What is the capital of France?'),
  ];
  final response = await client.chat(messages, options: {'model': 'gpt-3.5-turbo'});
  print(response.message.parts.first.toString());
}
```

### 2. Streaming with Ollama (Test Server)

```dart
import 'package:flutter_ai/flutter_ai.dart';
import 'dart:io';

void main() async {
  final ollamaClient = OllamaClient(
    baseUrl: 'http://5.149.249.212:11434/api',
  );
  final client = FlutterAiClient(provider: ollamaClient);
  final messages = [
    AiMessage.user('Why is the sky blue? Write a short poem.'),
  ];
  final stream = client.chatStream(messages, options: {'model': 'llama2'});
  await for (final chunk in stream) {
    stdout.write(chunk.content);
  }
  print('');
}
```
