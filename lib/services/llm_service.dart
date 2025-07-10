import 'package:shared_preferences/shared_preferences.dart';
import '../api/anthropic_adapter.dart';
import '../api/gemini_adapter.dart';
import '../api/llm_api_adapter.dart';
import '../api/openai_adapter.dart';
import '../api/openrouter_adapter.dart';
import '../models/llm_response.dart';
import 'secure_storage_service.dart';

enum LlmProvider { openAI, gemini, anthropic, openRouter }

class LlmService {
  final SecureStorageService _secureStorageService = SecureStorageService();

  LlmApiAdapter _getAdapter(LlmProvider provider) {
    switch (provider) {
      case LlmProvider.openAI:
        return OpenAiApiAdapter();
      case LlmProvider.gemini:
        return GeminiApiAdapter();
      case LlmProvider.anthropic:
        return AnthropicApiAdapter();
      case LlmProvider.openRouter:
        return OpenRouterApiAdapter();

    }
  }

  Future<LlmResponse> getCorrection(String text) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = await _secureStorageService.getApiKey();
    final providerName = prefs.getString('llm_provider') ?? LlmProvider.openAI.name;
    final modelName = prefs.getString('llm_model_name');

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API Key not found. Please set it in the settings.');
    }

    final provider = LlmProvider.values.firstWhere((e) => e.name == providerName);
    final adapter = _getAdapter(provider);

    return await adapter.getCorrection(text, apiKey, modelName);
  }
}
