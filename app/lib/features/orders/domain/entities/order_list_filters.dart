import 'package:freezed_annotation/freezed_annotation.dart';

import 'order_entity.dart';

part 'order_list_filters.freezed.dart';

enum OrderRoleFilter { all, buyer, farmer }

@freezed
abstract class OrderListFilters with _$OrderListFilters {
  const factory OrderListFilters({
    @Default(OrderRoleFilter.all) OrderRoleFilter role,
    OrderStatus? status,
    @Default(1) int page,
  }) = _OrderListFilters;
}
