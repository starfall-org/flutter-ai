import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_ai/core/models/ai_tool.dart';

/// A client for interacting with a Model Context Protocol (MCP) server.
class McpClient {
  final String baseUrl;
  final http.Client _httpClient;

  McpClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Fetches the list of available tools from the MCP server.
  Future<List<AiTool>> getTools() async {
    final response = await _httpClient.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'prompt': {'messages': []}}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      final toolsList = jsonResponse['tools'] as List?;
      if (toolsList == null) {
        return [];
      }
      return toolsList.map((toolJson) {
        final functionDef = toolJson['function'];
        return AiTool(
          name: functionDef['name'],
          description: functionDef['description'],
          parameters: functionDef['parameters'] as Map<String, dynamic>,
        );
      }).toList();
    } else {
      throw Exception(
          'Failed to get tools from MCP server: ${response.statusCode} ${response.body}');
    }
  }

  void close() {
    _httpClient.close();
  }
}
