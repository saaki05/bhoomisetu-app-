import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/order_list_filters.dart';
import '../models/order_model.dart';

part 'orders_remote_datasource.g.dart';

class OrdersRemoteDataSource {
  OrdersRemoteDataSource(this._client);

  final ApiClient _client;

  Future<(List<OrderModel> items, Map<String, dynamic>? meta)> listOrders(
    OrderListFilters filters,
  ) {
    return _client.getWithMeta<List<OrderModel>>(
      ApiConstants.orders,
      queryParameters: {
        if (filters.role != OrderRoleFilter.all) 'role': filters.role.name,
        if (filters.status != null) 'status': filters.status!.apiValue,
        'page': filters.page,
      },
      parser: (json) => (json as List)
          .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Future<OrderModel> getOrder(String id) {
    return _client.get<OrderModel>(
      ApiConstants.order(id),
      parser: (json) =>
          OrderModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<OrderModel> createOrder(Map<String, dynamic> payload) {
    return _client.post<OrderModel>(
      ApiConstants.orders,
      data: payload,
      parser: (json) =>
          OrderModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<OrderModel> updateStatus(
    String id, {
    required String status,
    String? note,
  }) {
    return _client.patch<OrderModel>(
      ApiConstants.orderStatus(id),
      data: {'status': status, 'note': ?note},
      parser: (json) =>
          OrderModel.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<void> submitReview(
    String orderId, {
    required int rating,
    String? comment,
  }) {
    return _client.post<void>(
      ApiConstants.orderReview(orderId),
      data: {'rating': rating, 'comment': ?comment},
    );
  }
}

@Riverpod(keepAlive: true)
OrdersRemoteDataSource ordersRemoteDataSource(OrdersRemoteDataSourceRef ref) =>
    OrdersRemoteDataSource(ref.watch(apiClientProvider));
