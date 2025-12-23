# flutter_ai

A unified Dart package for interacting with various AI APIs.

This library provides a consistent and simple interface for accessing generative AI models from providers like OpenAI, Anthropic, Google AI, and Ollama. It offers a standardized data model and a unified client to abstract away the complexities of each individual API.

## Features

- **Unified Client**: A single client (`FlutterAiClient`) to interact with multiple AI providers.
- **Standardized Models**: Consistent request and response models (`AiMessage`, `AiChatResponse`, etc.).
- **Streaming Support**: Built-in support for streaming chat responses from all providers.
- **Provider-Specific Access**: Option to use individual clients (`OpenAIClient`, `AnthropicClient`, etc.) for provider-specific features.
- **MCP Integration**: Includes a client for discovering tools from MCP-compliant servers, with support for the full OAuth 2.1 authorization code flow.

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_ai: ^0.0.1
```

Then, run `dart pub get` or `flutter pub get`.

## Usage

For detailed usage examples, including how to use the unified client, provider-specific clients, streaming, and tool-calling with MCP and OAuth 2.1, please see the comprehensive example file located at `example/unified_client_example.dart`.

This example demonstrates best practices for initializing clients with API keys from environment variables and showcases the full capabilities of the package.
