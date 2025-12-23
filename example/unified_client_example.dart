import 'dart:io';

import 'package:flutter_ai/flutter_ai.dart';
import 'package:flutter_ai/core/models/ai_request.dart';
import 'package:flutter_ai/core/models/ai_message.dart';
import 'package:flutter_ai/clients/mcp_client.dart';

// This example demonstrates how to use the unified AI client to interact
// with different providers and functionalities, including MCP tool integration.

// --- IMPORTANT ---
// 1. Set your API keys as environment variables before running this example.
//    e.g., export OPENAI_API_KEY='your_key_here'
// 2. This example uses top-level async `await`, so it should be run with
//    `dart run example/unified_client_example.dart`.

void main() async {
  // --- Setup ---
  final apiKey = Platform.environment['OPENAI_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('Error: OPENAI_API_KEY environment variable is not set.');
    print('Please set your API key before running this example.');
    exit(1);
  }

  // --- MCP Client Setup ---
  // Replace with your actual MCP server URL.
  // For this example, we'll use a placeholder.
  const mcpServerUrl = 'https://search-mcp.parallel.ai/mcp';
  final mcpClient = McpClient(baseUrl: mcpServerUrl);

  final openAI = FlutterAiClient.openai(apiKey: apiKey, mcpClient: mcpClient);

  print('--- Unified AI Client Example ---');

  // --- 1. List Models ---
  try {
    print('\nFetching models from OpenAI...');
    final modelsResponse = await openAI.getModels();
    final modelsToShow = modelsResponse.models.take(5);
    print('Successfully fetched ${modelsResponse.models.length} models. Showing first ${modelsToShow.length}:');
    for (final model in modelsToShow) {
      print('  - ID: ${model.id}, Owned by: ${model.ownedBy}');
    }
  } catch (e) {
    print('An error occurred while fetching models: $e');
  }

  // --- 2. MCP Tool Integration and Chat ---
  try {
    print('\nFetching tools from MCP server...');
    // In a real app, you might handle authentication here if required by the MCP server.
    final tools = await openAI.mcpClient!.getTools();
    print('Successfully fetched ${tools.length} tools.');

    print('\n--- Chat with MCP Tools ---');
    final chatMessages = [
      AiMessage.user('What is the weather like in Boston?'),
    ];

    print('Sending chat request with tools...');
    final chatResponse = await openAI.createChat(
      chatMessages,
      options: {
        'model': 'gpt-4o',
        'tools': tools,
      },
    );

    final assistantMessage = chatResponse.message;
    final toolCall = assistantMessage.parts.whereType<AiToolCallContent>().firstOrNull?.toolCalls.first;

    if (toolCall != null) {
      print('AI wants to call a tool: ${toolCall.name}');
      print('Arguments: ${toolCall.arguments}');
      // Here, you would execute the tool and send the result back to the AI.
    } else {
      final textResponse = assistantMessage.parts.whereType<AiTextContent>().first.text;
      print('AI Response: $textResponse');
    }
  } catch (e) {
    print('An error occurred during MCP integration or chat: $e');
  }

  // --- 3. Get Embeddings ---
  try {
    print('\nCreating embeddings for a sample text...');
    final embeddingsResponse = await openAI.getEmbeddings(
      const AiEmbeddingRequest(
        model: 'text-embedding-3-small',
        input: ['Hello, world!', 'This is a test.'],
      ),
    );
    print('Successfully created ${embeddingsResponse.embeddings.length} embeddings.');
    for (final embedding in embeddingsResponse.embeddings) {
      final vectorSnippet = embedding.values.take(5).join(', ');
      print('  - Embedding: [${vectorSnippet}, ...]');
    }
  } catch (e) {
    print('An error occurred while creating embeddings: $e');
  }

  // --- 4. Generate an Image ---
  try {
    print('\nGenerating an image with DALL-E 3...');
    final imageResponse = await openAI.createImage(
      const AiImageRequest(
        model: 'dall-e-3',
        prompt: 'A cute baby sea otter floating on its back, holding a vibrant, colorful seashell. The style should be a high-quality, detailed illustration.',
        n: 1,
        size: '1024x1024',
      ),
    );
    print('Successfully generated image!');
    if (imageResponse.images.isNotEmpty) {
      final imageUrl = imageResponse.images.first.data;
      print('  - Image URL: $imageUrl');
    }
  } catch (e) {
    print('An unexpected error occurred while generating the image: $e');
  }
}
