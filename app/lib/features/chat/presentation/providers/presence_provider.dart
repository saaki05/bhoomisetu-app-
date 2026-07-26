import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/socket_client.dart';

part 'presence_provider.g.dart';

@riverpod
class IsUserOnline extends _$IsUserOnline {
  StreamSubscription<Map<String, dynamic>>? _sub;

  @override
  Future<bool> build(String userId) async {
    final client = ref.watch(socketClientProvider);
    ref.onDispose(() => _sub?.cancel());

    _sub = client.onPresenceUpdate.listen((event) {
      if (event['userId'] == userId) state = AsyncData(event['isOnline'] as bool);
    });

    final result = await client.queryPresence([userId]);
    return result[userId] ?? false;
  }
}
