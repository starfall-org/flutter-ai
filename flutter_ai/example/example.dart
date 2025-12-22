
import 'package:flutter_ai/clients/anthropic/anthropic_client.dart';
import 'package:flutter_ai/clients/google/google_ai_client.dart';
import 'package:flutter_ai/clients/mcp_client.dart';
import 'package:flutter_ai/clients/openai/openai_client.dart';
import 'package:flutter_ai/core/models/ai_message.dart';
import 'package:flutter_ai/core/models/ai_response.dart';
import 'package:flutter_ai/core/models/ai_tool.dart';
import 'package:flutter_ai/core/models/tool.dart';
import 'dart:io' show Platform;

void main() async {
  print('--- Running OpenAI Example ---');
  await _runOpenAIExample();
  print('\n--- Running Anthropic Example ---');
  await _runAnthropicExample();
  print('\n--- Running Google AI Example ---');
  await _runGoogleAIExample();
}

Future<void> _runOpenAIExample() async {
  // 1. Initialize MCP Client with new authenticated endpoint
  final mcpApiKey = Platform.environment['MCP_API_KEY'];
  if (mcpApiKey == null) {
    print('Error: MCP_API_KEY not set. Skipping MCP tool fetching.');
    return;
  }
  final mcpClient = McpClient(
    baseUrl: 'https://search-mcp.parallel.ai/mcp',
    apiKey: mcpApiKey,
  );

  List<AiTool> availableTools = [];
  try {
    print('Fetching tools from MCP server...');
    availableTools = await mcpClient.getTools();
    print('Successfully fetched ${availableTools.length} tools.');
  } catch (e) {
    print('Error fetching tools: $e');
  }

  // 2. Initialize OpenAI Client
  final openAIApiKey = Platform.environment['OPENAI_API_KEY'];
  if (openAIApiKey == null) {
    print('Error: OPENAI_API_KEY not set. Skipping OpenAI example.');
    return;
  }
  final openAIClient = OpenAIClient(apiKey: openAIApiKey);

  // 3. Create a message to trigger a tool call
  final messages = [
    AiMessage.user(
      content: 'Please generate a 2-second video of a blue square rotating.',
    ),
  ];

  print('Sending chat request to OpenAI...');
  try {
    // 4. Send the request with tools
    final AiChatResponse response = await openAIClient.createChat(
      messages,
      options: {
        'model': 'gpt-4-turbo',
        'tools': availableTools,
      },
    );

    // 5. Process the response
    final toolCallPart = response.message.parts.whereType<AiToolCallContent>().firstOrNull;
    if (toolCallPart != null) {
      print('OpenAI responded with a tool call request:');
      final toolCall = toolCallPart.toolCalls.first;
      print('  - Tool Name: ${toolCall.name}');
      print('  - Arguments: ${toolCall.arguments}');
    } else {
      print('OpenAI responded with a message: ${response.message.textContent}');
    }
  } catch (e) {
    print('Error during OpenAI chat: $e');
  }
}

Future<void> _runAnthropicExample() async {
  final apiKey = Platform.environment['ANTHROPIC_API_KEY'];
  if (apiKey == null) {
    print('Error: ANTHROPIC_API_KEY not set. Skipping Anthropic example.');
    return;
  }
  final anthropicClient = AnthropicClient(apiKey: apiKey);

  final messages = [AiMessage.user(content: 'Hello from Anthropic!')];

  print('Sending chat request to Anthropic...');
  try {
    final AiChatResponse response = await anthropicClient.createChat(
      messages,
      options: {'model': 'claude-3-sonnet-20240229'},
    );
    print('Anthropic responded with a message: ${response.message.textContent}');
  } catch (e) {
    print('Error during Anthropic chat: $e');
  }
}

Future<void> _runGoogleAIExample() async {
  final apiKey = Platform.environment['GOOGLE_API_KEY'];
  if (apiKey == null) {
    print('Error: GOOGLE_API_KEY not set. Skipping Google AI example.');
    return;
  }
  final googleClient = GoogleAIClient(apiKey: apiKey);

  final messages = [AiMessage.user(content: 'Hello from Google AI!')];

  print('Sending chat request to Google AI...');
  try {
    final AiChatResponse response = await googleClient.createChat(
      messages,
      options: {'model': 'gemini-pro'},
    );
    print('Google AI responded with a message: ${response.message.textContent}');
  } catch (e) {
    print('Error during Google AI chat: $e');
  }
}
