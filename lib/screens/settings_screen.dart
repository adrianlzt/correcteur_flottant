import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/llm_service.dart';
import '../services/secure_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _secureStorage = SecureStorageService();
  final _apiKeyController = TextEditingController();
  final _modelNameController = TextEditingController();
  LlmProvider _selectedProvider = LlmProvider.openAI;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = await _secureStorage.getApiKey();
    final providerName = prefs.getString('llm_provider') ?? LlmProvider.openAI.name;
    final modelName = prefs.getString('llm_model_name') ?? '';

    setState(() {
      _apiKeyController.text = apiKey ?? '';
      _modelNameController.text = modelName;
      _selectedProvider = LlmProvider.values.firstWhere((e) => e.name == providerName);
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.saveApiKey(_apiKeyController.text);
    await prefs.setString('llm_provider', _selectedProvider.name);
    await prefs.setString('llm_model_name', _modelNameController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
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
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text('Save Settings'),
                  ),
                ],
              ),
            ),
    );
  }
}
