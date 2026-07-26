import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../network/network_info.dart';
import '../theme/app_colors.dart';

part 'offline_banner.g.dart';

@riverpod
Stream<bool> isOnline(IsOnlineRef ref) => ref.watch(networkInfoProvider).onConnectivityChanged;

/// Thin banner that slides in above app content whenever connectivity is
/// lost, and slides away once it's restored. Mount once near the root of
/// each feature shell (not per-screen) so it doesn't reset on navigation.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider).valueOrNull ?? true;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      child: isOnline
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              color: AppColors.warning,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 16, color: Colors.white),
                  SizedBox(width: 8),
                  Text('You are offline', style: TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
            ),
    );
  }
}
