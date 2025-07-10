import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/llm_response.dart';
import 'llm_api_adapter.dart';
import 'system_prompt.dart';

class OpenAiApiAdapter implements LlmApiAdapter {
  @override
  Future<LlmResponse> getCorrection(String text, String apiKey, String? modelName, {String? language}) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({
      'model': modelName != null && modelName.isNotEmpty ? modelName : 'gpt-4o',
      'messages': [
        {'role': 'system', 'content': getSystemPrompt(language: language ?? 'English')},
        {'role': 'user', 'content': text},
      ],
      'temperature': 0.2,
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
        throw Exception('Failed to get correction from OpenAI. Status code: ${response.statusCode}\nBody: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error communicating with OpenAI: $e');
    }
  }
}
