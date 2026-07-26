import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/states/async_value_widget.dart';
import '../../../../core/widgets/states/shimmer_box.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/orders_list_controller.dart';
import '../widgets/order_card.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        ref.read(ordersListControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg, vertical: AppConstants.spaceSm),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _StatusFilterChip(label: 'All', selected: ordersState.valueOrNull?.filters.status == null, status: null),
                  const SizedBox(width: AppConstants.spaceSm),
                  for (final status in OrderStatus.values)
                    Padding(
                      padding: const EdgeInsets.only(right: AppConstants.spaceSm),
                      child: _StatusFilterChip(
                        label: status.label,
                        selected: ordersState.valueOrNull?.filters.status == status,
                        status: status,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: AsyncValueWidget<OrdersListState>(
              value: ordersState,
              loading: () => const ShimmerListPlaceholder(),
              onRetry: () => ref.read(ordersListControllerProvider.notifier).refresh(),
              isEmpty: (state) => state.items.isEmpty,
              emptyMessage: 'No orders yet',
              emptyIcon: Icons.receipt_long_outlined,
              data: (state) => RefreshIndicator(
                onRefresh: () => ref.read(ordersListControllerProvider.notifier).refresh(),
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppConstants.spaceLg),
                  itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: AppConstants.spaceSm),
                  itemBuilder: (context, index) {
                    if (index >= state.items.length) {
                      return const ShimmerBox(height: 88, borderRadius: AppConstants.radiusMd, width: double.infinity);
                    }
                    final order = state.items[index];
                    return OrderCard(
                      order: order,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends ConsumerWidget {
  const _StatusFilterChip({required this.label, required this.selected, required this.status});

  final String label;
  final bool selected;
  final OrderStatus? status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => ref.read(ordersListControllerProvider.notifier).setStatusFilter(status),
    );
  }
}
