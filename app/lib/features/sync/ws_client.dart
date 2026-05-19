import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/constants.dart';

typedef OnChangeCallback = void Function();

class WsClient {
  final String serverUrl;
  final String token;
  final OnChangeCallback onServerChange;

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Duration _reconnectDelay = AppConstants.wsReconnectBase;
  bool _disposed = false;

  WsClient({
    required this.serverUrl,
    required this.token,
    required this.onServerChange,
  });

  void connect() {
    if (_disposed) return;
    try {
      final wsUrl = serverUrl.replaceFirst('http', 'ws');
      _channel = WebSocketChannel.connect(
        Uri.parse('$wsUrl/api/ws?token=$token'),
      );
      _channel!.stream.listen(
        _onMessage,
        onDone: _scheduleReconnect,
        onError: (_) => _scheduleReconnect(),
      );
      _reconnectDelay = AppConstants.wsReconnectBase;
    } catch (e) {
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = data['type'] as String?;
      if (type == 'change' || type == 'sync_complete') {
        onServerChange();
      }
    } catch (_) {}
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectDelay = Duration(
        seconds: (_reconnectDelay.inSeconds * 2)
            .clamp(1, AppConstants.wsReconnectMax.inSeconds),
      );
      connect();
    });
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
  }
}
