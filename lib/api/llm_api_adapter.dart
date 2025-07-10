import '../models/llm_response.dart';

abstract class LlmApiAdapter {
  Future<LlmResponse> getCorrection(String text, String apiKey, String? modelName, {String? language});
}
