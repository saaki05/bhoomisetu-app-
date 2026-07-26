import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/order_usecases.dart';

part 'create_order_controller.g.dart';

@riverpod
class CreateOrderController extends _$CreateOrderController {
  @override
  void build() {}

  Future<Either<Failure, OrderEntity>> submit({
    required String listingId,
    required double quantity,
    required String deliveryAddress,
    String? deliveryDistrict,
    String? deliveryState,
    String? deliveryPincode,
    required String contactPhone,
    String? notes,
  }) {
    return ref.read(createOrderUseCaseProvider).call(
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
