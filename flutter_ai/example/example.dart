import 'dart:io';
import 'package:flutter_ai/flutter_ai.dart';

// To run this file:
// `dart run example/example.dart`
//
// To run the Anthropic/Google AI examples, you must set environment variables.
void main() async {
  print('--- Running Flutter AI Examples ---');

  await _runOpenAIExample();
  await _runOllamaStreamExample();
  // We will skip the direct MCP example as the test server is problematic.
  // await _runMcpExample();
  await _runAnthropicExample();
  await _runGoogleAIExample();
  await _runToolCallExample();

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
  print('\n--- Example 3: MCP Tool Discovery (Skipped) ---');
  print('Skipping due to problematic test server.');
}

Future<void> _runAnthropicExample() async {
  print('\n--- Example 4: Anthropic Chat Completion ---');
  final apiKey = Platform.environment['ANTHROPIC_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('Skipping Anthropic example: ANTHROPIC_API_KEY is not set.');
    return;
  }
  // ... (rest of the function is the same)
}

Future<void> _runGoogleAIExample() async {
  print('\n--- Example 5: Google AI Chat Completion ---');
  final apiKey = Platform.environment['GOOGLE_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('Skipping Google AI example: GOOGLE_API_KEY is not set.');
    return;
  }
  // ... (rest of the function is the same)
}

/// Example 6: Tool Calling with a Mocked Tool and OpenAI
Future<void> _runToolCallExample() async {
  print('\n--- Example 6: Tool Calling Integration Test ---');
  try {
    // 1. Define a tool manually
    print('Defining a mock weather tool...');
    final weatherTool = AiTool(
      name: 'get_weather',
      description: 'Get the current weather in a given location',
      parameters: {
        'type': 'object',
        'properties': {
          'location': {'type': 'string', 'description': 'The city and state, e.g. San Francisco, CA'},
          'unit': {'type': 'string', 'enum': ['celsius', 'fahrenheit']},
        },
        'required': ['location'],
      },
    );
    print('Using tool: ${weatherTool.name}');

    // 2. Set up the OpenAI client
    final openAiClient = OpenAIClient(
      baseUrl: 'https://oi-vscode-server-0501.onrender.com/v1',
      apiKey: 'no-key-needed',
    );
    final client = FlutterAiClient(provider: openAiClient);

    // 3. Create a prompt to trigger the tool
    final messages = [AiMessage.user('thời tiết ở hà nội hôm nay thế nào?')];

    // 4. Make the call with the tool
    print('Calling chat model with the weather tool...');
    final response = await client.chat(
      messages,
      options: {'model': 'gpt-3.5-turbo', 'tools': [weatherTool], 'tool_choice': 'auto'},
    );

    // 5. Check the response for a tool call
    final toolCallPart = response.message.parts.whereType<AiToolCallContent>().firstOrNull;
    if (toolCallPart != null) {
      print('Model wants to call a tool!');
      for (final toolCall in toolCallPart.toolCalls) {
        print('  - Tool Name: ${toolCall.name}');
        print('  - Tool Call ID: ${toolCall.id}');
        print('  - Arguments: ${toolCall.arguments}');
      }
    } else {
      print('Model did not return a tool call. It responded with text.');
    }
  } catch (e) {
    print('Tool Calling Example Failed: $e');
  }
}
