import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../data/repositories_impl/orders_repository_impl.dart';
import '../entities/order_entity.dart';
import '../entities/order_list_filters.dart';
import '../repositories/orders_repository.dart';

part 'order_usecases.g.dart';

class ListOrdersUseCase {
  ListOrdersUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, PaginatedOrders>> call(OrderListFilters filters) => _repository.listOrders(filters);
}

class GetOrderUseCase {
  GetOrderUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, OrderEntity>> call(String id) => _repository.getOrder(id);
}

class CreateOrderUseCase {
  CreateOrderUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, OrderEntity>> call({
    required String listingId,
    required double quantity,
    required String deliveryAddress,
    String? deliveryDistrict,
    String? deliveryState,
    String? deliveryPincode,
    required String contactPhone,
    String? notes,
  }) {
    return _repository.createOrder(
      listingId: listingId,
      quantity: quantity,
      deliveryAddress: deliveryAddress,
      deliveryDistrict: deliveryDistrict,
      deliveryState: deliveryState,
      deliveryPincode: deliveryPincode,
      contactPhone: contactPhone,
      notes: notes,
    );
  }
}

class UpdateOrderStatusUseCase {
  UpdateOrderStatusUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, OrderEntity>> call(String id, {required OrderStatus status, String? note}) =>
      _repository.updateStatus(id, status: status, note: note);
}

class SubmitOrderReviewUseCase {
  SubmitOrderReviewUseCase(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, Unit>> call(String orderId, {required int rating, String? comment}) =>
      _repository.submitReview(orderId, rating: rating, comment: comment);
}

@riverpod
ListOrdersUseCase listOrdersUseCase(ListOrdersUseCaseRef ref) => ListOrdersUseCase(ref.watch(ordersRepositoryProvider));

@riverpod
GetOrderUseCase getOrderUseCase(GetOrderUseCaseRef ref) => GetOrderUseCase(ref.watch(ordersRepositoryProvider));

@riverpod
CreateOrderUseCase createOrderUseCase(CreateOrderUseCaseRef ref) =>
    CreateOrderUseCase(ref.watch(ordersRepositoryProvider));

@riverpod
UpdateOrderStatusUseCase updateOrderStatusUseCase(UpdateOrderStatusUseCaseRef ref) =>
    UpdateOrderStatusUseCase(ref.watch(ordersRepositoryProvider));

@riverpod
SubmitOrderReviewUseCase submitOrderReviewUseCase(SubmitOrderReviewUseCaseRef ref) =>
    SubmitOrderReviewUseCase(ref.watch(ordersRepositoryProvider));
