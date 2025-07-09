import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/llm_response.dart';
import 'llm_service.dart'; // For the systemPrompt constant and abstract class

class OpenAiAdapter implements LlmApiAdapter {
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  @override
  Future<LlmResponse> getCorrection(String text, String apiKey, {String? model}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      'model': model ?? 'gpt-4o', // Default to gpt-4o if no model is specified
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': text},
      ],
      'response_format': { 'type': 'json_object' }
    });

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      final messageContent = responseBody['choices'][0]['message']['content'];
      // The message content itself is a JSON string, so it needs to be decoded again.
      return LlmResponse.fromJson(jsonDecode(messageContent));
    } else {
      final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception('Failed to get correction from OpenAI. Status: ${response.statusCode}, Body: ${errorBody['error']['message']}');
    }
  }
}
