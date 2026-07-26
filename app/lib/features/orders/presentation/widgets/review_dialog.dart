import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/usecases/order_usecases.dart';

Future<void> showReviewDialog(BuildContext context, WidgetRef ref, String orderId) {
  return showDialog(context: context, builder: (_) => _ReviewDialog(ref: ref, orderId: orderId));
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog({required this.ref, required this.orderId});

  final WidgetRef ref;
  final String orderId;

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final result = await widget.ref.read(submitOrderReviewUseCaseProvider).call(
          widget.orderId,
          rating: _rating,
          comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) => context.showSnackBar(failure.message, isError: true),
      (_) {
        Navigator.of(context).pop();
        context.showSnackBar('Thanks for your review!');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate this farmer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return IconButton(
                icon: Icon(
                  starIndex <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.amber.shade700,
                ),
                onPressed: () => setState(() => _rating = starIndex),
              );
            }),
          ),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Share your experience (optional)'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        AppButton(label: 'Submit', isLoading: _isSubmitting, fullWidth: false, onPressed: _submit),
      ],
    );
  }
}
