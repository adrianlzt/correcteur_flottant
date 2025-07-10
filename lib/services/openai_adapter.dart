import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/llm_api_adapter.dart';
import '../models/llm_response.dart';

class OpenAiAdapter implements LlmApiAdapter {
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  final String _systemPrompt = '''
You are an expert French language tutor. Your task is to analyze the user's French text. You MUST respond with a JSON object. Do not add any text before or after the JSON object.

The JSON object must have this exact structure:
{
  "correctedText": "The fully corrected, natural-sounding French text.",
  "errors": [
    {
      "type": "A brief category of the error (e.g., 'Accord de genre', 'Conjugaison', 'Préposition', 'Vocabulaire', 'Ordre des mots', 'Article', 'Pronom', 'Autre').",
      "original": "The specific incorrect part of the text.",
      "corrected": "The corrected version of that part.",
      "explanation": "A clear and simple explanation of the error and the correction, in French."
    }
  ]
}
''';

  @override
  Future<LlmResponse> getCorrection(String text, String apiKey, String? modelName) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      'model': modelName != null && modelName.isNotEmpty ? modelName : 'gpt-4o',
      'messages': [
        {'role': 'system', 'content': _systemPrompt},
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
