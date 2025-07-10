import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/llm_response.dart';
import 'llm_api_adapter.dart';

class OpenRouterApiAdapter implements LlmApiAdapter {
  final String _systemPrompt = '''
  You are an expert French language tutor. Your task is to analyze the user's French text.

  You MUST respond in the following format and nothing else:
  1. The fully corrected, natural-sounding French text.
  2. The separator '---|||---'.
  3. A clear and simple explanation of the corrections made.

  Example:
  <corrected text>---|||---<explanation of errors>

  - If the user's text is perfect and has no errors, return only the original text without the separator or explanation.
  - Do not include any text, notes, or apologies outside of this format.
  ''';

  @override
  Future<LlmResponse> getCorrection(String text, String apiKey, String? modelName) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
      'HTTP-Referer': 'http://localhost:3000', // Required by OpenRouter
      'X-Title': 'Correcteur Flottant', // Recommended by OpenRouter
    };
    final body = jsonEncode({
      'model': modelName != null && modelName.isNotEmpty ? modelName : 'deepseek/deepseek-r1-0528-qwen3-8b:free',
      'messages': [
        {'role': 'system', 'content': _systemPrompt},
        {'role': 'user', 'content': text},
      ],
      'temperature': 0.2,
      'max_tokens': 2048,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final content = responseBody['choices'][0]['message']['content'] as String;

        const separator = '---|||---';
        final parts = content.split(separator);

        final correctedText = parts[0].trim();

        if (parts.length > 1) {
          final explanation = parts[1].trim();
          final errorDetail = ErrorDetail(
            type: 'Explanation',
            original: '',
            corrected: '',
            explanation: explanation,
          );
          return LlmResponse(correctedText: correctedText, errors: [errorDetail]);
        } else {
          // No separator found, assume no errors.
          return LlmResponse(correctedText: correctedText, errors: []);
        }
      } else {
        throw Exception('Failed to get correction from OpenRouter. Status code: ${response.statusCode}\nBody: ${response.body}');
      }
    } catch (e) {
      // This will catch network errors and other issues with the request itself.
      throw Exception('Error communicating with OpenRouter: $e');
    }
  }
}
