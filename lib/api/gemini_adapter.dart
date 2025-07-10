import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/llm_response.dart';
import 'llm_api_adapter.dart';
import 'system_prompt.dart';

class GeminiApiAdapter implements LlmApiAdapter {
  @override
  Future<LlmResponse> getCorrection(String text, String apiKey, String? modelName, {String? language}) async {
    final model = modelName != null && modelName.isNotEmpty ? modelName : 'gemini-1.5-flash';
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': getSystemPrompt(language: language ?? 'English')},
            {'text': text}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.2,
      }
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final content = responseBody['candidates'][0]['content']['parts'][0]['text'] as String;

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
        throw Exception('Failed to get correction from Gemini. Status code: ${response.statusCode}\nBody: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error communicating with Gemini: $e');
    }
  }
}
