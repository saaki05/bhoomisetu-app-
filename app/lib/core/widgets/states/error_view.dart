import 'package:flutter/material.dart';

import '../../exceptions/failure.dart';
import '../app_button.dart';

/// Shown when a request fails outright. [failure] drives the icon/message
/// so a network drop reads differently from a 500 or a permission error.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.failure, this.onRetry});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (icon, message) = switch (failure) {
      NetworkFailure(:final message) => (Icons.wifi_off_rounded, message),
      UnauthorizedFailure(:final message) => (Icons.lock_outline_rounded, message),
      PermissionFailure(:final message) => (Icons.block_rounded, message),
      ValidationFailure(:final message) => (Icons.error_outline_rounded, message),
      ServerFailure(:final message) => (Icons.cloud_off_rounded, message),
      CacheFailure(:final message) => (Icons.storage_rounded, message),
      UnknownFailure(:final message) => (Icons.error_outline_rounded, message),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              AppButton(label: 'Retry', onPressed: onRetry, fullWidth: false, icon: Icons.refresh_rounded),
            ],
          ],
        ),
      ),
    );
  }
}
