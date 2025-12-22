
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/models/tool.dart';

class McpClient {
  final String baseUrl;
  final String? apiKey;

  McpClient({required this.baseUrl, this.apiKey});

  Future<List<AiTool>> getTools() async {
    final url = Uri.parse(baseUrl); // No trailing slash needed
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (apiKey != null) {
      headers['Authorization'] = 'Bearer $apiKey';
    }

    final body = jsonEncode({
      'jsonrpc': '2.0',
      'method': 'tools/list',
      'params': {},
      'id': 1,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // The new server returns a standard JSON response.
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (data['error'] != null) {
          throw Exception('MCP server returned an error: ${data['error']['message']}');
        }

        final result = data['result'];
        if (result != null && result['tools'] is List) {
          return (result['tools'] as List).map((toolJson) {
            return AiTool(
              name: toolJson['name'],
              description: toolJson['description'],
              parameters: toolJson['inputSchema'] ?? {},
            );
          }).toList();
        } else {
          throw Exception('Invalid response format: "tools" list not found');
        }
      } else {
        throw Exception('Failed to load tools from MCP: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to MCP server: $e');
    }
  }
}
