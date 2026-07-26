import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/states/async_value_widget.dart';
import '../../../authentication/presentation/providers/auth_controller.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/order_usecases.dart';
import '../providers/order_detail_provider.dart';
import '../providers/orders_list_controller.dart';
import '../widgets/order_status_chip.dart';
import '../widgets/review_dialog.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final currentUserId = ref.watch(authControllerProvider).valueOrNull?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Order details')),
      body: AsyncValueWidget<OrderEntity>(
        value: orderAsync,
        onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        data: (order) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.listingTitle ?? 'Order',
                      style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  OrderStatusChip(status: order.status),
                ],
              ),
              const SizedBox(height: AppConstants.spaceLg),
              _SummaryCard(order: order),
              const SizedBox(height: AppConstants.spaceLg),
              Text('Delivery details', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppConstants.spaceSm),
              Text(order.deliveryAddress ?? '—', style: context.textTheme.bodyMedium),
              if (order.contactPhone != null)
                Text('Contact: ${order.contactPhone}', style: context.textTheme.bodyMedium),
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spaceSm),
                Text('Notes: ${order.notes}', style: context.textTheme.bodyMedium),
              ],
              const SizedBox(height: AppConstants.spaceLg),
              Text('Status timeline', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppConstants.spaceSm),
              _StatusTimeline(history: order.history),
              const SizedBox(height: AppConstants.spaceXl),
              _ActionButtons(order: order, currentUserId: currentUserId),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        children: [
          _row(context, 'Quantity', '${order.quantity.toStringAsFixed(0)} ${order.unit}'),
          _row(context, 'Unit price', '₹${order.unitPrice.toStringAsFixed(0)}'),
          const Divider(),
          _row(context, 'Total', '₹${order.totalPrice.toStringAsFixed(0)}', emphasize: true),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
          Text(
            value,
            style: emphasize
                ? context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: context.colors.primary)
                : context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.history});

  final List<OrderStatusEvent> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Text('No history yet', style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant));
    }
    return Column(
      children: history.map((event) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.circle, size: 10, color: context.colors.primary),
              const SizedBox(width: AppConstants.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.status.label, style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      DateTime.parse(event.createdAt).toDisplayDateTime,
                      style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                    ),
                    if (event.note != null && event.note!.isNotEmpty)
                      Text(event.note!, style: context.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ActionButtons extends ConsumerStatefulWidget {
  const _ActionButtons({required this.order, required this.currentUserId});

  final OrderEntity order;
  final String? currentUserId;

  @override
  ConsumerState<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends ConsumerState<_ActionButtons> {
  bool _isSubmitting = false;

  Future<void> _updateStatus(OrderStatus status) async {
    setState(() => _isSubmitting = true);

    final result = await ref.read(updateOrderStatusUseCaseProvider).call(widget.order.id, status: status);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) => context.showSnackBar(failure.message, isError: true),
      (_) {
        ref.invalidate(orderDetailProvider(widget.order.id));
        ref.invalidate(ordersListControllerProvider);
        context.showSnackBar('Order updated to ${status.label}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isFarmer = widget.currentUserId == order.farmerId;
    final isBuyer = widget.currentUserId == order.buyerId;

    final buttons = <Widget>[];

    if (isFarmer) {
      switch (order.status) {
        case OrderStatus.pending:
          buttons.addAll([
            AppButton(label: 'Accept order', isLoading: _isSubmitting, onPressed: () => _updateStatus(OrderStatus.accepted)),
            const SizedBox(height: AppConstants.spaceSm),
            AppButton(
              label: 'Reject order',
              variant: AppButtonVariant.outlined,
              isLoading: _isSubmitting,
              onPressed: () => _updateStatus(OrderStatus.rejected),
            ),
          ]);
        case OrderStatus.accepted:
          buttons.add(AppButton(
              label: 'Mark as preparing', isLoading: _isSubmitting, onPressed: () => _updateStatus(OrderStatus.preparing)));
        case OrderStatus.preparing:
          buttons.add(AppButton(
              label: 'Mark out for delivery',
              isLoading: _isSubmitting,
              onPressed: () => _updateStatus(OrderStatus.outForDelivery)));
        case OrderStatus.outForDelivery:
          buttons.add(AppButton(
              label: 'Mark delivered', isLoading: _isSubmitting, onPressed: () => _updateStatus(OrderStatus.delivered)));
        default:
          break;
      }
    }

    if (isBuyer) {
      if (order.status == OrderStatus.pending || order.status == OrderStatus.accepted) {
        buttons.add(AppButton(
          label: 'Cancel order',
          variant: AppButtonVariant.outlined,
          isLoading: _isSubmitting,
          onPressed: () => _updateStatus(OrderStatus.cancelled),
        ));
      }
      if (order.status == OrderStatus.delivered) {
        buttons.add(AppButton(
          label: 'Leave a review',
          icon: Icons.star_outline_rounded,
          onPressed: () => showReviewDialog(context, ref, order.id),
        ));
      }
    }

    if (buttons.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: buttons);
  }
}
