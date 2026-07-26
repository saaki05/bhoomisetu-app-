import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/order_usecases.dart';

part 'order_detail_provider.g.dart';

@riverpod
Future<OrderEntity> orderDetail(OrderDetailRef ref, String orderId) async {
  final result = await ref.watch(getOrderUseCaseProvider).call(orderId);
  return result.fold((failure) => throw failure, (order) => order);
}
