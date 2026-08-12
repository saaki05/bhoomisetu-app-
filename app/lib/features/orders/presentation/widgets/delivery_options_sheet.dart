import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/order_entity.dart';

/// Porter has no public deep-link API for pre-filling a booking, so this is
/// deliberately just a redirection: it hands the buyer the farmer's pickup
/// address and phone number to paste into Porter themselves, then tries to
/// open the installed Porter app directly — falling back to its store
/// listing when the app isn't installed.
const _porterAndroidPackage = 'com.theporter.android.customerapp';
const _porterAndroidAppUri = 'android-app://$_porterAndroidPackage';
const _porterPlayStoreUrl = 'https://play.google.com/store/apps/details?id=$_porterAndroidPackage';
const _porterAppStoreUrl = 'https://apps.apple.com/in/app/porter-logistics-service-app/id1109398410';
const _porterWebUrl = 'https://porter.in';

/// Tries the installed app first; if that fails (not installed, or the
/// platform can't resolve an `android-app://` intent), falls back to the
/// platform store listing so the buyer can install it.
Future<void> _openPorter() async {
  if (kIsWeb) {
    await launchUrlString(_porterWebUrl, mode: LaunchMode.externalApplication);
    return;
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    final openedApp = await canLaunchUrlString(_porterAndroidAppUri) &&
        await launchUrlString(_porterAndroidAppUri);
    if (!openedApp) {
      await launchUrlString(_porterPlayStoreUrl, mode: LaunchMode.externalApplication);
    }
    return;
  }

  if (defaultTargetPlatform == TargetPlatform.iOS) {
    // No confirmed custom URL scheme is published for Porter's iOS app, so
    // rather than guess one (which would silently fail), this goes straight
    // to its App Store listing.
    await launchUrlString(_porterAppStoreUrl, mode: LaunchMode.externalApplication);
    return;
  }

  await launchUrlString(_porterWebUrl, mode: LaunchMode.externalApplication);
}

Future<void> showDeliveryOptionsSheet(BuildContext context, OrderEntity order) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _DeliveryOptionsSheet(order: order),
  );
}

class _DeliveryOptionsSheet extends StatelessWidget {
  const _DeliveryOptionsSheet({required this.order});

  final OrderEntity order;

  Future<void> _copy(BuildContext context, String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) context.showSnackBar('$label copied');
  }

  @override
  Widget build(BuildContext context) {
    final farmer = order.farmer;

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
            Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: context.colors.primary),
                const SizedBox(width: AppConstants.spaceSm),
                Text('Arrange your own delivery', style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              "BhoomiSetu doesn't book couriers directly. Copy the pickup details below, "
              'then open Porter to book a rider — paste this in as the pickup point.',
              style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            _DetailRow(
              icon: Icons.person_outline_rounded,
              label: 'Farmer',
              value: farmer?.fullName ?? '—',
              onCopy: farmer == null ? null : () => _copy(context, 'Name', farmer.fullName),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Pickup address',
              value: farmer?.pickupAddress ?? 'Not provided by the farmer yet',
              onCopy: farmer?.pickupAddress == null ? null : () => _copy(context, 'Address', farmer!.pickupAddress!),
            ),
            if (farmer?.phone != null) ...[
              const SizedBox(height: AppConstants.spaceSm),
              _DetailRow(
                icon: Icons.call_outlined,
                label: 'Farmer phone',
                value: farmer!.phone!,
                onCopy: () => _copy(context, 'Phone number', farmer.phone!),
              ),
            ],
            const SizedBox(height: AppConstants.spaceXl),
            AppButton(
              label: 'Open Porter',
              icon: Icons.open_in_new_rounded,
              onPressed: _openPorter,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value, this.onCopy});

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: context.colors.onSurfaceVariant),
        const SizedBox(width: AppConstants.spaceSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
              Text(value, style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(icon: const Icon(Icons.copy_rounded, size: 18), onPressed: onCopy, tooltip: 'Copy'),
      ],
    );
  }
}
