import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_entity.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(50)),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  Color _colorFor(OrderStatus status) => switch (status) {
        OrderStatus.pending => AppColors.warning,
        OrderStatus.accepted || OrderStatus.preparing || OrderStatus.outForDelivery => AppColors.info,
        OrderStatus.delivered => AppColors.success,
        OrderStatus.rejected || OrderStatus.cancelled => AppColors.danger,
        OrderStatus.refunded => AppColors.soilBrown,
      };
}
