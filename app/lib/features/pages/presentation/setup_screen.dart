import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/token_storage.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _urlController = TextEditingController(text: 'http://');
  final _tokenController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() { _loading = true; _error = null; });

    final url = _urlController.text.trim().replaceAll(RegExp(r'/+$'), '');
    final token = _tokenController.text.trim();

    try {
      final dio = Dio(BaseOptions(
        baseUrl: url,
        connectTimeout: const Duration(seconds: 8),
        headers: {'Authorization': 'Bearer $token'},
      ));
      await dio.get('/api/pages');

      await ref.read(tokenStorageProvider).save(serverUrl: url, apiToken: token);
      if (mounted) context.go('/pages');
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.statusCode == 401
            ? 'Invalid token'
            : 'Could not connect: ${e.message}';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Connect to your server',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'Server URL',
                    hintText: 'http://192.168.1.100:8080',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _tokenController,
                  decoration: const InputDecoration(
                    labelText: 'API Token',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  autocorrect: false,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _connect,
                  child: _loading
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Connect'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
