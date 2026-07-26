import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../exceptions/failure.dart';
import '../../utils/app_logger.dart';
import 'empty_view.dart';
import 'error_view.dart';

/// Renders a Riverpod [AsyncValue] through the four states every screen in
/// this app must support: loading, error, empty, and data. Pass [failureOf]
/// only when the thrown error is a domain [Failure] wrapped some other way;
/// by default the widget assumes the provider throws [Failure] directly
/// (the convention used by every controller in this codebase).
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.onRetry,
    this.isEmpty,
    this.emptyMessage = 'Nothing here yet',
    this.emptyIcon = Icons.inbox_outlined,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;
  final String emptyMessage;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loading?.call() ?? const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        AppLogger.e('AsyncValueWidget error', error, stackTrace);
        final failure = error is Failure ? error : const Failure.unknown();
        return ErrorView(failure: failure, onRetry: onRetry);
      },
      data: (result) {
        if (isEmpty != null && isEmpty!(result)) {
          return EmptyView(message: emptyMessage, icon: emptyIcon);
        }
        return data(result);
      },
    );
  }
}
