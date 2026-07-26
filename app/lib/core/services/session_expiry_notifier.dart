import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_expiry_notifier.g.dart';

/// Cross-cutting signal fired when the network layer determines the current
/// session can no longer be refreshed (refresh token expired/revoked).
/// The auth module listens to this to clear its state and the router
/// listens to it to redirect to the login screen — without the network
/// layer needing to depend on either.
class SessionExpiryNotifier {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get onSessionExpired => _controller.stream;

  void notifySessionExpired() {
    if (!_controller.isClosed) _controller.add(null);
  }

  void dispose() => _controller.close();
}

@Riverpod(keepAlive: true)
SessionExpiryNotifier sessionExpiryNotifier(SessionExpiryNotifierRef ref) {
  final notifier = SessionExpiryNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
}
