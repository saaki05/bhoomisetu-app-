import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/exceptions/failure.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_list_filters.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_datasource.dart';

part 'orders_repository_impl.g.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._remote);

  final OrdersRemoteDataSource _remote;

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on AppException catch (e) {
      return Left(failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, PaginatedOrders>> listOrders(
    OrderListFilters filters,
  ) {
    return _guard(() async {
      final (items, meta) = await _remote.listOrders(filters);
      return PaginatedOrders(
        items: items.map((m) => m.toEntity()).toList(),
        page: (meta?['page'] as num?)?.toInt() ?? filters.page,
        pageSize: (meta?['pageSize'] as num?)?.toInt() ?? 20,
        total: (meta?['total'] as num?)?.toInt() ?? items.length,
        totalPages: (meta?['totalPages'] as num?)?.toInt() ?? 1,
      );
    });
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrder(String id) =>
      _guard(() async => (await _remote.getOrder(id)).toEntity());

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
    required String listingId,
    required double quantity,
    required String deliveryAddress,
    String? deliveryDistrict,
    String? deliveryState,
    String? deliveryPincode,
    required String contactPhone,
    String? notes,
  }) {
    return _guard(() async {
      final model = await _remote.createOrder({
        'listingId': listingId,
        'quantity': quantity,
        'deliveryAddress': deliveryAddress,
        'deliveryDistrict': ?deliveryDistrict,
        'deliveryState': ?deliveryState,
        'deliveryPincode': ?deliveryPincode,
        'contactPhone': contactPhone,
        'notes': ?notes,
      });
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, OrderEntity>> updateStatus(
    String id, {
    required OrderStatus status,
    String? note,
  }) {
    return _guard(
      () async => (await _remote.updateStatus(
        id,
        status: status.apiValue,
        note: note,
      )).toEntity(),
    );
  }

  @override
  Future<Either<Failure, Unit>> submitReview(
    String orderId, {
    required int rating,
    String? comment,
  }) {
    return _guard(() async {
      await _remote.submitReview(orderId, rating: rating, comment: comment);
      return unit;
    });
  }
}

@Riverpod(keepAlive: true)
OrdersRepository ordersRepository(OrdersRepositoryRef ref) =>
    OrdersRepositoryImpl(ref.watch(ordersRemoteDataSourceProvider));
