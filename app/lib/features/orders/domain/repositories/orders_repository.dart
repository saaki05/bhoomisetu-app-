import 'package:dartz/dartz.dart';

import '../../../../core/exceptions/failure.dart';
import '../entities/order_entity.dart';
import '../entities/order_list_filters.dart';

abstract class OrdersRepository {
  Future<Either<Failure, PaginatedOrders>> listOrders(OrderListFilters filters);

  Future<Either<Failure, OrderEntity>> getOrder(String id);

  Future<Either<Failure, OrderEntity>> createOrder({
    required String listingId,
    required double quantity,
    required String deliveryAddress,
    String? deliveryDistrict,
    String? deliveryState,
    String? deliveryPincode,
    required String contactPhone,
    String? notes,
  });

  Future<Either<Failure, OrderEntity>> updateStatus(String id, {required OrderStatus status, String? note});

  Future<Either<Failure, Unit>> submitReview(String orderId, {required int rating, String? comment});
}
