import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/order_entity.dart';

part 'order_model.g.dart';

@JsonSerializable(createToJson: false)
class OrderPartyModel {
  OrderPartyModel({required this.id, required this.fullName, this.avatarUrl, this.phone});

  factory OrderPartyModel.fromJson(Map<String, dynamic> json) => _$OrderPartyModelFromJson(json);

  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? phone;

  OrderParty toEntity() => OrderParty(id: id, fullName: fullName, avatarUrl: avatarUrl, phone: phone);
}

@JsonSerializable(createToJson: false)
class OrderStatusEventModel {
  OrderStatusEventModel({required this.status, this.note, required this.createdAt});

  factory OrderStatusEventModel.fromJson(Map<String, dynamic> json) => _$OrderStatusEventModelFromJson(json);

  final String status;
  final String? note;
  final String createdAt;

  OrderStatusEvent toEntity() =>
      OrderStatusEvent(status: OrderStatus.fromApiValue(status), note: note, createdAt: createdAt);
}

@JsonSerializable(createToJson: false)
class OrderModel {
  OrderModel({
    required this.id,
    required this.buyerId,
    required this.farmerId,
    required this.listingId,
    this.listingTitle,
    this.listingImage,
    required this.quantity,
    required this.unitPrice,
    required this.unit,
    required this.totalPrice,
    required this.status,
    this.deliveryAddress,
    this.deliveryDistrict,
    this.deliveryState,
    this.deliveryPincode,
    this.contactPhone,
    this.notes,
    this.buyer,
    this.farmer,
    this.history,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);

  final String id;
  final String buyerId;
  final String farmerId;
  final String listingId;
  final String? listingTitle;
  final String? listingImage;
  final double quantity;
  final double unitPrice;
  final String unit;
  final double totalPrice;
  final String status;
  final String? deliveryAddress;
  final String? deliveryDistrict;
  final String? deliveryState;
  final String? deliveryPincode;
  final String? contactPhone;
  final String? notes;
  final OrderPartyModel? buyer;
  final OrderPartyModel? farmer;
  final List<OrderStatusEventModel>? history;
  final String createdAt;
  final String updatedAt;

  OrderEntity toEntity() => OrderEntity(
        id: id,
        buyerId: buyerId,
        farmerId: farmerId,
        listingId: listingId,
        listingTitle: listingTitle,
        listingImage: listingImage,
        quantity: quantity,
        unitPrice: unitPrice,
        unit: unit,
        totalPrice: totalPrice,
        status: OrderStatus.fromApiValue(status),
        deliveryAddress: deliveryAddress,
        deliveryDistrict: deliveryDistrict,
        deliveryState: deliveryState,
        deliveryPincode: deliveryPincode,
        contactPhone: contactPhone,
        notes: notes,
        buyer: buyer?.toEntity(),
        farmer: farmer?.toEntity(),
        history: history?.map((e) => e.toEntity()).toList() ?? const [],
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
