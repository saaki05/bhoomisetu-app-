import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_entity.freezed.dart';

enum OrderStatus {
  pending,
  accepted,
  rejected,
  preparing,
  outForDelivery,
  delivered,
  cancelled,
  refunded;

  static OrderStatus fromApiValue(String value) => switch (value) {
        'pending' => OrderStatus.pending,
        'accepted' => OrderStatus.accepted,
        'rejected' => OrderStatus.rejected,
        'preparing' => OrderStatus.preparing,
        'out_for_delivery' => OrderStatus.outForDelivery,
        'delivered' => OrderStatus.delivered,
        'cancelled' => OrderStatus.cancelled,
        _ => OrderStatus.refunded,
      };

  String get apiValue => switch (this) {
        OrderStatus.pending => 'pending',
        OrderStatus.accepted => 'accepted',
        OrderStatus.rejected => 'rejected',
        OrderStatus.preparing => 'preparing',
        OrderStatus.outForDelivery => 'out_for_delivery',
        OrderStatus.delivered => 'delivered',
        OrderStatus.cancelled => 'cancelled',
        OrderStatus.refunded => 'refunded',
      };

  String get label => switch (this) {
        OrderStatus.pending => 'Pending',
        OrderStatus.accepted => 'Accepted',
        OrderStatus.rejected => 'Rejected',
        OrderStatus.preparing => 'Preparing',
        OrderStatus.outForDelivery => 'Out for delivery',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
        OrderStatus.refunded => 'Refunded',
      };
}

@freezed
abstract class OrderParty with _$OrderParty {
  const factory OrderParty({required String id, required String fullName, String? avatarUrl, String? phone}) =
      _OrderParty;
}

@freezed
abstract class OrderStatusEvent with _$OrderStatusEvent {
  const factory OrderStatusEvent({required OrderStatus status, String? note, required String createdAt}) =
      _OrderStatusEvent;
}

@freezed
abstract class OrderEntity with _$OrderEntity {
  const factory OrderEntity({
    required String id,
    required String buyerId,
    required String farmerId,
    required String listingId,
    String? listingTitle,
    String? listingImage,
    required double quantity,
    required double unitPrice,
    required String unit,
    required double totalPrice,
    required OrderStatus status,
    String? deliveryAddress,
    String? deliveryDistrict,
    String? deliveryState,
    String? deliveryPincode,
    String? contactPhone,
    String? notes,
    OrderParty? buyer,
    OrderParty? farmer,
    @Default([]) List<OrderStatusEvent> history,
    required String createdAt,
    required String updatedAt,
  }) = _OrderEntity;
}

@freezed
abstract class PaginatedOrders with _$PaginatedOrders {
  const factory PaginatedOrders({
    required List<OrderEntity> items,
    required int page,
    required int pageSize,
    required int total,
    required int totalPages,
  }) = _PaginatedOrders;
}
