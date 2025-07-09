import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const _apiKey = 'api_key';

  Future<void> saveApiKey(String key) async {
    await _storage.write(key: _apiKey, value: key);
  }

  Future<String?> getApiKey() async {
    return await _storage.read(key: _apiKey);
  }
}
