import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/home_summary_entity.dart';

Future<void> showSchemeDetailSheet(BuildContext context, GovernmentSchemePreview scheme) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _SchemeDetailSheet(scheme: scheme),
  );
}

class _SchemeDetailSheet extends StatelessWidget {
  const _SchemeDetailSheet({required this.scheme});

  final GovernmentSchemePreview scheme;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            Chip(label: Text(scheme.category)),
            const SizedBox(height: AppConstants.spaceSm),
            Text(scheme.title, style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppConstants.spaceMd),
            Text(scheme.description, style: context.textTheme.bodyMedium),
            if (scheme.deadline != null) ...[
              const SizedBox(height: AppConstants.spaceMd),
              Row(
                children: [
                  Icon(Icons.event_outlined, size: 18, color: context.colors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text('Deadline: ${scheme.deadline}', style: context.textTheme.bodySmall),
                ],
              ),
            ],
            const SizedBox(height: AppConstants.spaceLg),
            if (scheme.applicationUrl != null)
              AppButton(
                label: 'View details / Apply',
                icon: Icons.open_in_new_rounded,
                onPressed: () => launchUrl(Uri.parse(scheme.applicationUrl!), mode: LaunchMode.externalApplication),
              ),
          ],
        ),
      ),
    );
  }
}
