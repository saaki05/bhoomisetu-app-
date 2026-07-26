import 'package:flutter/material.dart';

enum AppButtonVariant { filled, outlined, text }

/// Standard button used across every form/action in the app. Wraps
/// Elevated/Outlined/TextButton with a built-in loading spinner so screens
/// never need to hand-roll `isLoading ? CircularProgressIndicator() : Text(...)`.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    final child = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: variant == AppButtonVariant.filled
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label);

    final button = switch (variant) {
      AppButtonVariant.filled => ElevatedButton(onPressed: isDisabled ? null : onPressed, child: child),
      AppButtonVariant.outlined => OutlinedButton(onPressed: isDisabled ? null : onPressed, child: child),
      AppButtonVariant.text => TextButton(onPressed: isDisabled ? null : onPressed, child: child),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
