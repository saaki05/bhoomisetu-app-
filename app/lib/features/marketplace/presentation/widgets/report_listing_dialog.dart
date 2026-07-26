import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/usecases/bookmark_usecases.dart';

Future<void> showReportListingDialog(BuildContext context, WidgetRef ref, String listingId) {
  return showDialog(context: context, builder: (_) => _ReportListingDialog(ref: ref, listingId: listingId));
}

class _ReportListingDialog extends StatefulWidget {
  const _ReportListingDialog({required this.ref, required this.listingId});

  final WidgetRef ref;
  final String listingId;

  @override
  State<_ReportListingDialog> createState() => _ReportListingDialogState();
}

class _ReportListingDialogState extends State<_ReportListingDialog> {
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reasonController.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);

    final result = await widget.ref
        .read(reportListingUseCaseProvider)
        .call(widget.listingId, reason: _reasonController.text.trim());

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) => context.showSnackBar(failure.message, isError: true),
      (_) {
        Navigator.of(context).pop();
        context.showSnackBar('Thanks — our team will review this listing.');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report this listing'),
      content: TextField(
        controller: _reasonController,
        maxLines: 3,
        decoration: const InputDecoration(hintText: 'What seems wrong with this listing?'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        AppButton(label: 'Submit', isLoading: _isSubmitting, fullWidth: false, onPressed: _submit),
      ],
    );
  }
}
