import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../domain/entities/home_summary_entity.dart';

class NearbyBuyerTile extends StatelessWidget {
  const NearbyBuyerTile({super.key, required this.buyer});

  final NearbyBuyer buyer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: context.colors.secondaryContainer,
            backgroundImage: buyer.avatarUrl != null ? NetworkImage(buyer.avatarUrl!) : null,
            child: buyer.avatarUrl == null
                ? Text(buyer.fullName.initials, style: TextStyle(color: context.colors.onSecondaryContainer))
                : null,
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            buyer.fullName,
            style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (buyer.village != null)
            Text(
              buyer.village!,
              style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade700),
              const SizedBox(width: 2),
              Text(
                buyer.totalReviews > 0 ? buyer.avgRating.toStringAsFixed(1) : 'New',
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
