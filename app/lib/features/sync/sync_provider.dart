import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../db/app_database.dart';
import '../auth/token_storage.dart';
import 'sync_service.dart';
import 'ws_client.dart';

enum SyncStatus { idle, syncing, error }

final syncProvider = AsyncNotifierProvider<SyncNotifier, SyncStatus>(
  SyncNotifier.new,
);

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

class SyncNotifier extends AsyncNotifier<SyncStatus> {
  SyncService? _syncService;
  WsClient? _wsClient;
  Timer? _periodicTimer;
  Timer? _debounceTimer;
  _LifecycleObserver? _observer;

  @override
  Future<SyncStatus> build() async {
    _observer = _LifecycleObserver(onResume: sync);
    WidgetsBinding.instance.addObserver(_observer!);

    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(_observer!);
      _periodicTimer?.cancel();
      _debounceTimer?.cancel();
      _wsClient?.dispose();
    });

    await _initSync();
    return SyncStatus.idle;
  }

  Future<void> _initSync() async {
    final storage = ref.read(tokenStorageProvider);
    final serverUrl = await storage.getServerUrl();
    final token = await storage.getApiToken();

    if (serverUrl == null || token == null) return;

    final dio = Dio(BaseOptions(
      baseUrl: serverUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Authorization': 'Bearer $token'},
    ));

    final db = ref.read(appDatabaseProvider);
    _syncService = SyncService(db: db, http: dio);

    _wsClient = WsClient(
      serverUrl: serverUrl,
      token: token,
      onServerChange: _debouncedSync,
    );
    _wsClient!.connect();

    _periodicTimer = Timer.periodic(AppConstants.syncInterval, (_) => sync());

    await sync();
  }

  Future<void> sync() async {
    if (_syncService == null) return;
    state = const AsyncData(SyncStatus.syncing);
    try {
      await _syncService!.sync();
      state = const AsyncData(SyncStatus.idle);
    } catch (_) {
      state = const AsyncData(SyncStatus.error);
    }
  }

  void triggerDirtySync() => _debouncedSync();

  void _debouncedSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(AppConstants.syncDebounce, sync);
  }
}

class _LifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResume;
  _LifecycleObserver({required this.onResume});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResume();
  }
}
