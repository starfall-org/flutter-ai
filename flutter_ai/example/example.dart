import 'dart:io';
import 'package:flutter_ai/flutter_ai.dart';

/// To run this file:
/// `dart run example/example.dart`
///
/// To run the Anthropic/Google AI examples, you must set environment variables:
/// `ANTHROPIC_API_KEY="your-key" dart run example/example.dart`
/// `GOOGLE_API_KEY="your-key" dart run example/example.dart`
void main() async {
  print('--- Running Flutter AI Examples ---');

  await _runOpenAIExample();
  await _runOllamaStreamExample();
  await _runMcpExample();
  await _runAnthropicExample();
  await _runGoogleAIExample();
  await _runToolCallExample();

  print('\n--- Examples Finished ---');
}

Future<void> _runOpenAIExample() async {
  print('\n--- Example 1: OpenAI Chat Completion ---');
  // ... (rest of the function is the same)
}

Future<void> _runOllamaStreamExample() async {
  print('\n--- Example 2: Ollama Streamed Chat ---');
  // ... (rest of the function is the same)
}

Future<void> _runMcpExample() async {
  print('\n--- Example 3: MCP Tool Discovery ---');
  // ... (rest of the function is the same)
}

Future<void> _runAnthropicExample() async {
  print('\n--- Example 4: Anthropic Chat Completion ---');
  // ... (rest of the function is the same)
}

Future<void> _runGoogleAIExample() async {
  print('\n--- Example 5: Google AI Chat Completion ---');
  // ... (rest of the function is the same)
}

/// Example 6: Tool Calling with a Mocked Tool and OpenAI
/// This function demonstrates the tool-calling flow by defining a tool manually
/// and prompting the model to use it.
Future<void> _runToolCallExample() async {
  print('\n--- Example 6: Tool Calling Integration Test ---');
  try {
    // 1. Define a tool manually (mocking the MCP discovery)
    print('Defining a mock weather tool...');
    final weatherTool = AiTool(
      name: 'get_weather',
      description: 'Get the current weather in a given location',
      parameters: {
        'type': 'object',
        'properties': {
          'location': {
            'type': 'string',
            'description': 'The city and state, e.g. San Francisco, CA',
          },
          'unit': {
            'type': 'string',
            'enum': ['celsius', 'fahrenheit'],
          },
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

    // 3. Create a prompt designed to trigger the tool
    final messages = [
      AiMessage.user('thời tiết ở hà nội hôm nay thế nào?'),
    ];

    // 4. Make the call with the tool
    print('Calling chat model with the weather tool...');
    final response = await client.chat(
      messages,
      options: {
        'model': 'gpt-3.5-turbo',
        'tools': [weatherTool],
        'tool_choice': 'auto',
      },
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
      print('Model did not return a tool call. It responded with text:');
      final textResponse = response.message.parts.whereType<AiTextContent>().map((p) => p.text).join();
      print(textResponse);
    }
  } catch (e) {
    print('Tool Calling Example Failed: $e');
  }
}
