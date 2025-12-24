# Comprehensive Guide to Using the flutter_ai Package

This guide provides a complete overview of the `flutter_ai` package, from initial setup to advanced usage. Whether you're building a simple chatbot or a complex, multi-provider AI application, this documentation will walk you through the process step by step.

## Table of Contents

1.  [Installation](#installation)
2.  [Authentication](#authentication)
3.  [Core Concepts](#core-concepts)
    -   [The Unified `FlutterAiClient`](#the-unified-flutteraiclient)
    -   [Provider-Specific Clients](#provider-specific-clients)
    -   [Standardized Models](#standardized-models)
4.  [Basic Usage: Creating a Chatbot](#basic-usage-creating-a-chatbot)
    -   [Initializing the Client](#initializing-the-client)
    -   [Sending a Chat Request](#sending-a-chat-request)
    -   [Handling the Response](#handling-the-response)
5.  [Advanced Usage](#advanced-usage)
    -   [Streaming Responses](#streaming-responses)
    -   [Listing Available Models](#listing-available-models)
    -   [Generating Embeddings](#generating-embeddings)
    -   [Image Generation](#image-generation)
6.  [Integrating with Flutter](#integrating-with-flutter)
    -   [Setting Up a Simple Flutter App](#setting-up-a-simple-flutter-app)
    -   [Building a Chat UI](#building-a-chat-ui)
7.  [Using the Model Context Protocol (MCP)](#using-the-model-context-protocol-mcp)
    -   [What is MCP?](#what-is-mcp)
    -   [Initializing `McpClient`](#initializing-mcpclient)

---

## 1. Installation

To get started, add the `flutter_ai` package to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_ai: ^0.0.1
```

Then, run `flutter pub get` in your terminal to install the package.

## 2. Authentication

The `flutter_ai` package authenticates with AI providers using API keys. The recommended way to handle these keys is by setting them as environment variables. The `FlutterAiClient` will automatically detect and use them.

Here are the environment variables for each provider:

-   **OpenAI:** `OPENAI_API_KEY`
-   **Anthropic:** `ANTHROPIC_API_KEY`
-   **Google AI:** `GOOGLE_API_KEY`

Set these variables in your development environment. For a Flutter application, a common approach is to use a `.env` file and load it at runtime.

## 3. Core Concepts

### The Unified `FlutterAiClient`

The `FlutterAiClient` is the primary entry point for the package. It provides a consistent interface for interacting with multiple AI providers, so you can write a single piece of code that works across different models.

### Provider-Specific Clients

For situations where you need to access provider-specific features, you can use the individual clients directly:

-   `OpenAIClient`
-   `AnthropicClient`
-   `GoogleAIClient`
-   `OllamaClient`

### Standardized Models

The package uses a set of standardized models for requests and responses (e.g., `AiMessage`, `AiChatResponse`) to ensure consistency across all providers.

## 4. Basic Usage: Creating a Chatbot

Here’s how to create a simple chatbot using the unified `FlutterAiClient`.

### Initializing the Client

First, create an instance of the `FlutterAiClient` for your desired provider.

```dart
import 'package:flutter_ai/flutter_ai.dart';

// Initialize the client for OpenAI
final client = FlutterAiClient.openai();

// Or for Anthropic
// final client = FlutterAiClient.anthropic();

// Or for Google AI
// final client = FlutterAiClient.google();
```

### Sending a Chat Request

Next, construct a list of `AiMessage` objects to represent the conversation history and send it to the `createChat` method.

```dart
final messages = [
  AiMessage.user(content: 'Why is the sky blue?'),
];

final response = await client.createChat(messages);
```

### Handling the Response

The `createChat` method returns an `AiChatResponse` object, which contains the model's reply.

```dart
if (response.choices.isNotEmpty) {
  final assistantMessage = response.choices.first.message;
  print(assistantMessage.content);
}
```

## 5. Advanced Usage

### Streaming Responses

For real-time applications, streaming is essential. Use the `createChatStream` method to receive the response as a stream of chunks.

```dart
final stream = client.createChatStream(messages);

await for (var chunk in stream) {
  final content = chunk.choices.first.delta?.content ?? '';
  print(content);
}
```

### Listing Available Models

You can fetch a list of available models from a provider using the `getModels` method.

```dart
final modelsResponse = await client.getModels();
final modelIds = modelsResponse.models.map((m) => m.id).toList();
print(modelIds);
```

### Generating Embeddings

To generate vector embeddings for a given text, use the `getEmbeddings` method.

```dart
final embeddingRequest = AiEmbeddingRequest(
  inputs: ['Hello, world!'],
  model: 'text-embedding-ada-002', // Example model
);

final embeddingResponse = await client.getEmbeddings(embeddingRequest);
print(embeddingResponse.embeddings.first.embedding);
```

### Image Generation

You can also generate images using the `createImage` method.

```dart
final imageRequest = AiImageRequest(
  prompt: 'A futuristic cityscape at sunset',
  n: 1,
  size: '1024x1024',
);

final imageResponse = await client.createImage(imageRequest);
print(imageResponse.data.first.url);
```

## 6. Integrating with Flutter

### Setting Up a Simple Flutter App

Here is a basic example of how to use `flutter_ai` in a Flutter widget.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ai/flutter_ai.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _client = FlutterAiClient.openai();
  String _response = '';

  void _sendMessage() async {
    final messages = [AiMessage.user(content: 'Tell me a fun fact.')];
    final response = await _client.createChat(messages);
    setState(() {
      _response = response.choices.first.message.content ?? 'No response.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter AI Chatbot')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_response),
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text('Get Fun Fact'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Building a Chat UI

For a more complete chat experience, you can build a UI with a `ListView` to display messages and a `TextField` for user input. The `createChatStream` method is ideal for updating the UI in real time as the model responds.

## 7. Using the Model Context Protocol (MCP)

### What is MCP?

MCP is a protocol that allows AI models to discover and interact with external tools and services. `flutter_ai` includes a `McpClient` for this purpose.

### Initializing `McpClient`

The `McpClient` can be passed to the `FlutterAiClient` during initialization.

```dart
final mcpClient = McpClient(
  mcpServerUrl: 'YOUR_MCP_SERVER_URL',
  clientId: 'YOUR_CLIENT_ID',
  redirectUri: 'YOUR_REDIRECT_URI',
);

final client = FlutterAiClient.openai(mcpClient: mcpClient);
```

This enables the `FlutterAiClient` to use the MCP server to discover and call tools as part of its chat completions.
