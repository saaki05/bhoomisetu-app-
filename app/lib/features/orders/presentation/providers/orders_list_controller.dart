import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_list_filters.dart';
import '../../domain/usecases/order_usecases.dart';

part 'orders_list_controller.freezed.dart';
part 'orders_list_controller.g.dart';

@freezed
abstract class OrdersListState with _$OrdersListState {
  const factory OrdersListState({
    required OrderListFilters filters,
    required List<OrderEntity> items,
    required int page,
    required int totalPages,
    @Default(false) bool isLoadingMore,
  }) = _OrdersListState;
}

@riverpod
class OrdersListController extends _$OrdersListController {
  @override
  Future<OrdersListState> build() => _fetch(const OrderListFilters());

  Future<OrdersListState> _fetch(OrderListFilters filters) async {
    final result = await ref.watch(listOrdersUseCaseProvider).call(filters);
    return result.fold(
      (failure) => throw failure,
      (paginated) => OrdersListState(
        filters: filters,
        items: paginated.items,
        page: paginated.page,
        totalPages: paginated.totalPages,
      ),
    );
  }

  Future<void> setStatusFilter(OrderStatus? status) async {
    final current = state.valueOrNull?.filters ?? const OrderListFilters();
    state = const AsyncLoading<OrdersListState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(current.copyWith(status: status, page: 1)));
  }

  Future<void> refresh() async {
    final filters = state.valueOrNull?.filters ?? const OrderListFilters();
    state = await AsyncValue.guard(() => _fetch(filters.copyWith(page: 1)));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || current.page >= current.totalPages) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await ref.read(listOrdersUseCaseProvider).call(current.filters.copyWith(page: current.page + 1));

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (paginated) => AsyncData(current.copyWith(
        items: [...current.items, ...paginated.items],
        page: paginated.page,
        totalPages: paginated.totalPages,
        isLoadingMore: false,
      )),
    );
  }
}
