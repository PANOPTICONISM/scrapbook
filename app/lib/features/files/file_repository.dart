import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/token_storage.dart';

typedef ServerConfig = ({String serverUrl, String token});

/// Resolved server URL + token, cached so widgets can build authenticated
/// file URLs synchronously.
final serverConfigProvider = FutureProvider<ServerConfig?>((ref) async {
  final storage = ref.watch(tokenStorageProvider);
  final url = await storage.getServerUrl();
  final token = await storage.getApiToken();
  if (url == null || token == null) return null;
  return (serverUrl: url, token: token);
});

final fileRepositoryProvider = Provider<FileRepository>(
  (ref) => FileRepository(ref),
);

class FileRepository {
  final Ref _ref;
  FileRepository(this._ref);

  static const _mimeByExt = {
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'svg': 'image/svg+xml',
  };

  /// Authenticated URL for displaying a stored file. The token rides in the
  /// query string so plain <img>/Image.network works (it can't set headers).
  static String imageUrl(ServerConfig cfg, String id) =>
      '${cfg.serverUrl}/api/files/$id?token=${Uri.encodeComponent(cfg.token)}';

  /// Opens the picker, uploads the chosen image, and returns its file id.
  /// Returns null if the user cancels.
  Future<String?> pickAndUploadImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final file = result?.files.singleOrNull;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return null;

    final mime = _mimeByExt[file.extension?.toLowerCase()] ?? 'image/png';
    final cfg = await _ref.read(serverConfigProvider.future);
    if (cfg == null) return null;

    final dio = Dio();
    try {
      // Send the bytes directly (not a Stream): dio frames it with a proper
      // Content-Length on native, and the browser adapter handles it on web —
      // a Stream body can't be sent over XHR on web.
      final resp = await dio.post(
        '${cfg.serverUrl}/api/files',
        data: bytes,
        options: Options(
          contentType: mime,
          headers: {'Authorization': 'Bearer ${cfg.token}'},
        ),
      );
      return (resp.data as Map)['id'] as String?;
    } on DioException catch (e) {
      debugPrint(
          'image upload failed: type=${e.type} status=${e.response?.statusCode} msg=${e.message} body=${e.response?.data}');
      rethrow;
    }
  }
}
