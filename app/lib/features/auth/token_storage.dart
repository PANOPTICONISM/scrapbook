import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

class TokenStorage {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<String?> getServerUrl() async =>
      (await _prefs).getString(AppConstants.serverUrlKey);

  Future<String?> getApiToken() async =>
      (await _prefs).getString(AppConstants.apiTokenKey);

  Future<void> save({required String serverUrl, required String apiToken}) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.serverUrlKey, serverUrl);
    await prefs.setString(AppConstants.apiTokenKey, apiToken);
  }

  Future<bool> get isConfigured async {
    final url = await getServerUrl();
    final token = await getApiToken();
    return url != null && url.isNotEmpty && token != null && token.isNotEmpty;
  }

  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(AppConstants.serverUrlKey);
    await prefs.remove(AppConstants.apiTokenKey);
  }
}
