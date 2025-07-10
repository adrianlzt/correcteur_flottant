import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/llm_api_adapter.dart';
import '../models/llm_response.dart';
import '../api/system_prompt.dart';

class OpenAiAdapter implements LlmApiAdapter {
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  @override
  Future<LlmResponse> getCorrection(String text, String apiKey, String? modelName, {String? language}) async {
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
    });

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
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
      final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception('Failed to get correction from OpenAI. Status: ${response.statusCode}, Body: ${errorBody['error']['message']}');
    }
  }
}
