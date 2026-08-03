import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Icon-first shortcuts to the screens/tools a farmer opens most, sitting
/// right under the hero header — mirrors the "quick access grid" pattern
/// common to agri-input apps, in BhoomiSetu's own palette.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({
    super.key,
    required this.onMarketplace,
    required this.onOrders,
    required this.onChat,
    required this.onFarmTools,
  });

  final VoidCallback onMarketplace;
  final VoidCallback onOrders;
  final VoidCallback onChat;
  final VoidCallback onFarmTools;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (icon: Icons.storefront_rounded, label: 'Marketplace', color: const Color(0xFF2E7D4F), onTap: onMarketplace),
      (icon: Icons.receipt_long_rounded, label: 'Orders', color: const Color(0xFFE8A33D), onTap: onOrders),
      (icon: Icons.chat_bubble_rounded, label: 'Chat', color: const Color(0xFF0288D1), onTap: onChat),
      (icon: Icons.calculate_rounded, label: 'Farm tools', color: const Color(0xFF8E24AA), onTap: onFarmTools),
    ];

    return Row(
      children: actions
          .map((action) => Expanded(
                child: _QuickActionTile(
                  icon: action.icon,
                  label: action.label,
                  color: action.color,
                  onTap: action.onTap,
                ),
              ))
          .toList(),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceSm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
