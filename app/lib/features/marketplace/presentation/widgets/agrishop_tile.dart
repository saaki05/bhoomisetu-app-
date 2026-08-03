import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../data/agrishop_mock_data.dart';

class AgrishopTile extends StatelessWidget {
  const AgrishopTile({super.key, required this.shop});

  final AgrishopPreview shop;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: context.colors.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(Icons.storefront_rounded, color: context.colors.primary, size: 20),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            shop.name,
            style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${shop.distanceKm.toStringAsFixed(1)} km away',
            style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          if (shop.verified) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, size: 14, color: context.colors.primary),
                const SizedBox(width: 4),
                Text('Verified', style: context.textTheme.bodySmall?.copyWith(color: context.colors.primary)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
