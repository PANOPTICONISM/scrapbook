class AppConstants {
  static const String serverUrlKey = 'server_url';
  static const String apiTokenKey = 'api_token';
  static const String lastSyncTimeKey = 'last_sync_time';
  static const Duration syncDebounce = Duration(seconds: 2);
  static const Duration syncInterval = Duration(seconds: 60);
  static const Duration wsReconnectBase = Duration(seconds: 1);
  static const Duration wsReconnectMax = Duration(seconds: 60);
}
