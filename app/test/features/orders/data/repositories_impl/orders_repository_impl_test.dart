import 'package:bhoomisetu/core/exceptions/app_exception.dart';
import 'package:bhoomisetu/core/exceptions/failure.dart';
import 'package:bhoomisetu/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:bhoomisetu/features/orders/data/models/order_model.dart';
import 'package:bhoomisetu/features/orders/data/repositories_impl/orders_repository_impl.dart';
import 'package:bhoomisetu/features/orders/domain/entities/order_entity.dart';
import 'package:bhoomisetu/features/orders/domain/entities/order_list_filters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockOrdersRemoteDataSource extends Mock implements OrdersRemoteDataSource {}

OrderModel _buildOrderModel({String status = 'pending'}) => OrderModel(
      id: 'order-1',
      buyerId: 'buyer-1',
      farmerId: 'farmer-1',
      listingId: 'listing-1',
      quantity: 5,
      unitPrice: 2200,
      unit: 'quintal',
      totalPrice: 11000,
      status: status,
      createdAt: '2026-07-25T00:00:00.000Z',
      updatedAt: '2026-07-25T00:00:00.000Z',
    );

void main() {
  late _MockOrdersRemoteDataSource remote;
  late OrdersRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const OrderListFilters());
  });

  setUp(() {
    remote = _MockOrdersRemoteDataSource();
    repository = OrdersRepositoryImpl(remote);
  });

  group('createOrder', () {
    test('sends the payload and returns the mapped entity', () async {
      when(() => remote.createOrder(any())).thenAnswer((_) async => _buildOrderModel());

      final result = await repository.createOrder(
        listingId: 'listing-1',
        quantity: 5,
        deliveryAddress: '123 Farm Road',
        contactPhone: '9876543210',
      );

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (order) {
        expect(order.id, 'order-1');
        expect(order.status, OrderStatus.pending);
      });
      final captured = verify(() => remote.createOrder(captureAny())).captured.single as Map<String, dynamic>;
      expect(captured['listingId'], 'listing-1');
      expect(captured.containsKey('deliveryDistrict'), isFalse);
    });

    test('maps a BadRequest ServerException to Failure.server', () async {
      when(() => remote.createOrder(any()))
          .thenThrow(const ServerException('Not enough quantity available', statusCode: 400, code: 'INSUFFICIENT_QUANTITY'));

      final result = await repository.createOrder(
        listingId: 'listing-1',
        quantity: 999,
        deliveryAddress: '123 Farm Road',
        contactPhone: '9876543210',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('updateStatus', () {
    test('forwards the api status value and returns the mapped entity', () async {
      when(() => remote.updateStatus('order-1', status: any(named: 'status'), note: any(named: 'note')))
          .thenAnswer((_) async => _buildOrderModel(status: 'accepted'));

      final result = await repository.updateStatus('order-1', status: OrderStatus.accepted);

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (order) => expect(order.status, OrderStatus.accepted));
      verify(() => remote.updateStatus('order-1', status: 'accepted', note: null)).called(1);
    });

    test('maps a PermissionException to Failure.permission', () async {
      when(() => remote.updateStatus(any(), status: any(named: 'status'), note: any(named: 'note')))
          .thenThrow(const PermissionException('Only the farmer can do that'));

      final result = await repository.updateStatus('order-1', status: OrderStatus.accepted);

      expect(result.isLeft(), isTrue);
      result.fold((failure) => expect(failure, isA<PermissionFailure>()), (_) => fail('expected Left'));
    });
  });
}
