import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/anthropic_adapter.dart';
import '../api/gemini_adapter.dart';
import '../api/llm_api_adapter.dart';
import '../api/openai_adapter.dart';
import '../api/openrouter_adapter.dart';
import '../services/llm_service.dart';
import '../services/secure_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _secureStorage = SecureStorageService();
  final _apiKeyController = TextEditingController();
  final _modelNameController = TextEditingController();
  LlmProvider _selectedProvider = LlmProvider.openRouter;
  String _selectedLanguage = 'English';
  bool _isLoading = true;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = await _secureStorage.getApiKey();
    final providerName = prefs.getString('llm_provider') ?? LlmProvider.openRouter.name;
    final modelName = prefs.getString('llm_model_name') ?? '';
    final language = prefs.getString('explanation_language') ?? 'English';

    setState(() {
      _apiKeyController.text = apiKey ?? '';
      _modelNameController.text = modelName;
      _selectedProvider = LlmProvider.values.firstWhere((e) => e.name == providerName);
      _selectedLanguage = language;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.saveApiKey(_apiKeyController.text);
    await prefs.setString('llm_provider', _selectedProvider.name);
    await prefs.setString('llm_model_name', _modelNameController.text);
    await prefs.setString('explanation_language', _selectedLanguage);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
    }
  }

  // This is a duplication of the private method in LlmService.
  // Consider refactoring LlmService to expose this if it's needed elsewhere.
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

  Future<void> _testSettings() async {
    if (_isTesting) return;

    setState(() {
      _isTesting = true;
    });

    try {
      final apiKey = _apiKeyController.text;

      if (apiKey.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('API Key is required for testing.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final adapter = _getAdapter(_selectedProvider);
      final modelName = _modelNameController.text;

      try {
        // Using a simple text to check for correction
        await adapter.getCorrection('test', apiKey, modelName, language: _selectedLanguage);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connection successful!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connection failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text('LLM Provider', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<LlmProvider>(
                    value: _selectedProvider,
                    isExpanded: true,
                    items: LlmProvider.values.map((provider) {
                      return DropdownMenuItem(
                        value: provider,
                        child: Text(provider.name),
                      );
                    }).toList(),
                    onChanged: (LlmProvider? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedProvider = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('API Key', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Enter your API Key',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Model Name (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _modelNameController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., gpt-4o, claude-3-haiku-20240307',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Explanation Language', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: _selectedLanguage,
                    isExpanded: true,
                    items: <String>['English', 'French'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedLanguage = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveSettings,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          child: const Text('Save Settings'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isTesting ? null : _testSettings,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          child: _isTesting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Test'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
