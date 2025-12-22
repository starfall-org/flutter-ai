import 'dart:io';
import 'package:flutter_ai/flutter_ai.dart';

/// To run this file:
/// `dart run example/example.dart`
///
/// To run the Anthropic example, you must set an environment variable:
/// `ANTHROPIC_API_KEY="your-api-key" dart run example/example.dart`
void main() async {
  print('--- Running Flutter AI Examples ---');

  await _runOpenAIExample();
  await _runOllamaStreamExample();
  await _runMcpExample();
  await _runAnthropicExample();

  print('\n--- Examples Finished ---');
}

Future<void> _runOpenAIExample() async {
  print('\n--- Example 1: OpenAI Chat Completion ---');
  final openAiClient = OpenAIClient(
    baseUrl: 'https://oi-vscode-server-0501.onrender.com/v1',
    apiKey: 'no-key-needed',
  );
  final client = FlutterAiClient(provider: openAiClient);
  final messages = [
    AiMessage.system('You are a helpful assistant.'),
    AiMessage.user('What is the capital of France?'),
  ];
  try {
    final response = await client.chat(messages, options: {'model': 'gpt-3.5-turbo'});
    final textResponse = response.message.parts.whereType<AiTextContent>().map((p) => p.text).join();
    print('AI Response: $textResponse');
    if (response.reasoning != null) {
      print('AI Reasoning: ${response.reasoning}');
    }
  } catch (e) {
    print('OpenAI Example Failed: $e');
  }
}

Future<void> _runOllamaStreamExample() async {
  print('\n--- Example 2: Ollama Streamed Chat ---');
  final ollamaClient = OllamaClient(
    baseUrl: 'http://5.149.249.212:11434/api',
  );
  final client = FlutterAiClient(provider: ollamaClient);
  final messages = [
    AiMessage.user('Why is the sky blue? Write a short poem.'),
  ];
  try {
    final stream = client.chatStream(messages, options: {'model': 'llama2'});
    print('AI Streamed Response:');
    await for (final chunk in stream) {
      stdout.write(chunk.content);
    }
    print('');
  } catch (e) {
    print('Ollama Example Failed: $e');
  }
}

Future<void> _runMcpExample() async {
  print('\n--- Example 3: MCP Tool Discovery ---');
  final mcpClient = McpClient(
    baseUrl: 'https://mcp-1st-birthday-anim-lab-ai.hf.space/gradio_api/mcp',
  );
  try {
    final tools = await mcpClient.getTools();
    print('Discovered ${tools.length} tools:');
    for (final tool in tools) {
      print('  - Tool: ${tool.name}');
      print('    Description: ${tool.description}');
    }
  } catch (e) {
    print('MCP Example Failed: $e');
  }
}

/// Example 4: Anthropic Chat Completion
/// This function demonstrates a call to the official Anthropic API.
/// It requires the ANTHROPIC_API_KEY environment variable to be set.
Future<void> _runAnthropicExample() async {
  print('\n--- Example 4: Anthropic Chat Completion ---');
  final apiKey = Platform.environment['ANTHROPIC_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    print('Skipping Anthropic example: ANTHROPIC_API_KEY is not set.');
    return;
  }

  final anthropicClient = AnthropicClient(apiKey: apiKey);
  final client = FlutterAiClient(provider: anthropicClient);

  final messages = [
    AiMessage.user('Hello, what is your name?'),
  ];

  try {
    final response = await client.chat(
      messages,
      options: {'model': 'claude-haiku-4-5-20251001'},
    );
    final textResponse = response.message.parts.whereType<AiTextContent>().map((p) => p.text).join();
    print('AI Response: $textResponse');
    // Note: As verified, reasoning is not expected from Anthropic's standard response.
    if (response.reasoning != null) {
      print('AI Reasoning: ${response.reasoning}');
    }
  } catch (e) {
    print('Anthropic Example Failed: $e');
  }
}
