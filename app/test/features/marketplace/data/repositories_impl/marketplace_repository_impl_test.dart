import 'package:bhoomisetu/core/exceptions/app_exception.dart';
import 'package:bhoomisetu/core/exceptions/failure.dart';
import 'package:bhoomisetu/features/marketplace/data/datasources/marketplace_remote_datasource.dart';
import 'package:bhoomisetu/features/marketplace/data/models/crop_listing_model.dart';
import 'package:bhoomisetu/features/marketplace/data/repositories_impl/marketplace_repository_impl.dart';
import 'package:bhoomisetu/features/marketplace/domain/entities/listing_draft.dart';
import 'package:bhoomisetu/features/marketplace/domain/entities/listing_search_filters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMarketplaceRemoteDataSource extends Mock implements MarketplaceRemoteDataSource {}

CropListingModel _buildListingModel({String id = 'listing-1'}) => CropListingModel(
      id: id,
      farmerId: 'farmer-1',
      categoryId: 'category-1',
      title: 'Fresh Wheat',
      status: 'active',
      pricePerUnit: 2200,
      unit: 'quintal',
      quantityAvailable: 40,
      isOrganic: false,
      avgRating: 0,
      totalReviews: 0,
      images: const [],
      createdAt: '2026-07-25T00:00:00.000Z',
    );

void main() {
  late _MockMarketplaceRemoteDataSource remote;
  late MarketplaceRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const ListingSearchFilters());
  });

  setUp(() {
    remote = _MockMarketplaceRemoteDataSource();
    repository = MarketplaceRepositoryImpl(remote);
  });

  group('searchListings', () {
    test('maps items and meta into a PaginatedListings on success', () async {
      when(() => remote.searchListings(any())).thenAnswer(
        (_) async => ([_buildListingModel()], {'page': 2, 'pageSize': 20, 'total': 25, 'totalPages': 2}),
      );

      final result = await repository.searchListings(const ListingSearchFilters(page: 2));

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (paginated) {
        expect(paginated.items, hasLength(1));
        expect(paginated.page, 2);
        expect(paginated.total, 25);
        expect(paginated.totalPages, 2);
      });
    });

    test('maps a ServerException to Failure.server', () async {
      when(() => remote.searchListings(any())).thenThrow(const ServerException('Server error', statusCode: 500));

      final result = await repository.searchListings(const ListingSearchFilters());

      expect(result.isLeft(), isTrue);
      result.fold((failure) => expect(failure, isA<ServerFailure>()), (_) => fail('expected Left'));
    });
  });

  group('createListing', () {
    test('sends the draft payload and returns the mapped entity', () async {
      when(() => remote.createListing(any())).thenAnswer((_) async => _buildListingModel());

      const draft = ListingDraft(
        categoryId: 'category-1',
        title: 'Fresh Wheat',
        pricePerUnit: 2200,
        quantityAvailable: 40,
      );

      final result = await repository.createListing(draft);

      expect(result.isRight(), isTrue);
      final captured = verify(() => remote.createListing(captureAny())).captured.single as Map<String, dynamic>;
      expect(captured['categoryId'], 'category-1');
      expect(captured['title'], 'Fresh Wheat');
      expect(captured.containsKey('description'), isFalse);
    });
  });

  group('toggleBookmark', () {
    test('returns the new bookmarked state', () async {
      when(() => remote.toggleBookmark('listing-1')).thenAnswer((_) async => true);

      final result = await repository.toggleBookmark('listing-1');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (bookmarked) => expect(bookmarked, isTrue));
    });

    test('maps a NetworkException to Failure.network', () async {
      when(() => remote.toggleBookmark(any())).thenThrow(const NetworkException());

      final result = await repository.toggleBookmark('listing-1');

      expect(result.isLeft(), isTrue);
      result.fold((failure) => expect(failure, isA<NetworkFailure>()), (_) => fail('expected Left'));
    });
  });
}
