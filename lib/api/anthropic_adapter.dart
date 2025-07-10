import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/llm_response.dart';
import 'llm_api_adapter.dart';
import 'system_prompt.dart';

class AnthropicApiAdapter implements LlmApiAdapter {
  @override
  Future<LlmResponse> getCorrection(String text, String apiKey, String? modelName, {String? language}) async {
    final url = Uri.parse('https://api.anthropic.com/v1/messages');
    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
    };
    final body = jsonEncode({
      'model': modelName != null && modelName.isNotEmpty ? modelName : 'claude-3-haiku-20240307',
      'max_tokens': 2048,
      'system': getSystemPrompt(language: language ?? 'English'),
      'messages': [
        {'role': 'user', 'content': text},
      ],
      'temperature': 0.2,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final content = responseBody['content'][0]['text'] as String;

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
        throw Exception('Failed to get correction from Anthropic. Status code: ${response.statusCode}\nBody: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error communicating with Anthropic: $e');
    }
  }
}
