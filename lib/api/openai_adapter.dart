import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/llm_response.dart';
import 'llm_api_adapter.dart';

class OpenAiApiAdapter implements LlmApiAdapter {
  final String _systemPrompt = '''
  You are an expert French language tutor. Your task is to analyze the user's French text. You MUST respond with a valid JSON object and nothing else.

  The JSON object must have this exact structure:
  {
    "correctedText": "The fully corrected, natural-sounding French text.",
    "errors": [
      {
        "type": "A brief category of the error (e.g., 'Accord de genre', 'Conjugaison', 'Préposition')",
        "original": "The incorrect part of the phrase.",
        "corrected": "The corrected part of the phrase.",
        "explanation": "A clear and simple explanation of the rule and why the correction was made."
      }
    ]
  }

  - If the user's text is perfect and has no errors, return the original text in "correctedText" and an empty array for "errors".
  - Do not include any text, notes, or apologies outside of the JSON object.
  ''';

  @override
  Future<LlmResponse> getCorrection(String text, String apiKey, String? modelName) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
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
      'temperature': 0.2,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final content = responseBody['choices'][0]['message']['content'];
        // The content itself is a JSON string, so we need to decode it again.
        final llmJson = jsonDecode(content);
        return LlmResponse.fromJson(llmJson);
      } else {
        throw Exception('Failed to get correction from OpenAI. Status code: ${response.statusCode}\nBody: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error communicating with OpenAI: $e');
    }
  }
}
