import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/home_summary_entity.dart';
import 'market_price_localizations.dart';

class MarketPriceCard extends StatelessWidget {
  const MarketPriceCard({super.key, required this.price});

  final MarketPrice price;

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
          Text(
            localizedMarketCropName(context, price.cropName),
            style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            price.marketName,
            style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            '₹${price.modalPrice.toStringAsFixed(0)}',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.primary,
            ),
          ),
          Text(
            localizedMarketPriceUnit(context, price.unit),
            style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            '₹${price.minPrice.toStringAsFixed(0)} - ₹${price.maxPrice.toStringAsFixed(0)}',
            style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
