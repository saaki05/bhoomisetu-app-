import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import '../utils/app_logger.dart';

part 'socket_client.g.dart';

/// Thin wrapper around the shared Socket.IO connection used by realtime
/// features (currently Chat). Connects lazily on first use and stays
/// connected for the app's lifetime — feature code subscribes to the
/// broadcast streams rather than touching the underlying socket directly.
class SocketClient {
  SocketClient(this._secureStorage);

  final SecureStorageService _secureStorage;
  io.Socket? _socket;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _readController = StreamController<Map<String, dynamic>>.broadcast();
  final _presenceController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get onMessage => _messageController.stream;
  Stream<Map<String, dynamic>> get onTyping => _typingController.stream;
  Stream<Map<String, dynamic>> get onRead => _readController.stream;
  Stream<Map<String, dynamic>> get onPresenceUpdate => _presenceController.stream;
  Stream<bool> get onConnectionChanged => _connectionController.stream;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (_socket != null) return;

    final token = await _secureStorage.accessToken;
    if (token == null) return;

    _socket = io.io(
      ApiConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableReconnection()
          .build(),
    );

    _socket!
      ..onConnect((_) {
        AppLogger.i('Socket connected');
        _connectionController.add(true);
      })
      ..onDisconnect((_) {
        AppLogger.i('Socket disconnected');
        _connectionController.add(false);
      })
      ..onConnectError((error) => AppLogger.w('Socket connect error: $error'))
      ..on('chat:message', (data) => _messageController.add(Map<String, dynamic>.from(data as Map)))
      ..on('chat:typing', (data) => _typingController.add(Map<String, dynamic>.from(data as Map)))
      ..on('chat:read', (data) => _readController.add(Map<String, dynamic>.from(data as Map)))
      ..on('presence:update', (data) => _presenceController.add(Map<String, dynamic>.from(data as Map)));
  }

  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String type,
    required String content,
  }) {
    final completer = Completer<Map<String, dynamic>>();
    _socket?.emitWithAck(
      'chat:send',
      {'conversationId': conversationId, 'type': type, 'content': content},
      ack: (response) => completer.complete(Map<String, dynamic>.from(response as Map)),
    );
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => {'success': false, 'error': 'Request timed out'},
    );
  }

  /// One-shot online/offline lookup for a set of users — used to seed
  /// presence state when a screen first opens, before any `presence:update`
  /// events have arrived.
  Future<Map<String, bool>> queryPresence(List<String> userIds) {
    if (_socket == null || userIds.isEmpty) return Future.value({});

    final completer = Completer<Map<String, bool>>();
    _socket!.emitWithAck(
      'presence:query',
      userIds,
      ack: (response) => completer.complete(Map<String, bool>.from(response as Map)),
    );
    return completer.future.timeout(const Duration(seconds: 5), onTimeout: () => {});
  }

  void sendTyping({required String conversationId, required bool isTyping}) {
    _socket?.emit('chat:typing', {'conversationId': conversationId, 'isTyping': isTyping});
  }

  Future<void> markRead(String conversationId) {
    final completer = Completer<void>();
    _socket?.emitWithAck('chat:read', {'conversationId': conversationId}, ack: (_) => completer.complete());
    return completer.future.timeout(const Duration(seconds: 10), onTimeout: () {});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _readController.close();
    _presenceController.close();
    _connectionController.close();
  }
}

@Riverpod(keepAlive: true)
SocketClient socketClient(SocketClientRef ref) {
  final client = SocketClient(ref.watch(secureStorageServiceProvider));
  ref.onDispose(client.dispose);
  return client;
}
