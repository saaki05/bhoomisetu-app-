import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' show MultipartFile;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/exceptions/failure.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/crop_listing_entity.dart';
import '../../domain/entities/listing_draft.dart';
import '../../domain/entities/listing_search_filters.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../datasources/marketplace_remote_datasource.dart';

part 'marketplace_repository_impl.g.dart';

Map<String, dynamic> _draftToPayload(ListingDraft draft) => {
  'categoryId': draft.categoryId,
  if (draft.farmId != null) 'farmId': draft.farmId,
  'title': draft.title,
  if (draft.description != null) 'description': draft.description,
  'pricePerUnit': draft.pricePerUnit,
  'unit': draft.unit,
  'quantityAvailable': draft.quantityAvailable,
  if (draft.suggestedMarketPrice != null)
    'suggestedMarketPrice': draft.suggestedMarketPrice,
  'isOrganic': draft.isOrganic,
  if (draft.harvestDate != null) 'harvestDate': draft.harvestDate,
  if (draft.district != null) 'district': draft.district,
  if (draft.state != null) 'state': draft.state,
  if (draft.village != null) 'village': draft.village,
  'status': draft.status,
};

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  MarketplaceRepositoryImpl(this._remote);

  final MarketplaceRemoteDataSource _remote;

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on AppException catch (e) {
      return Left(failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() => _guard(
    () async =>
        (await _remote.getCategories()).map((c) => c.toEntity()).toList(),
  );

  @override
  Future<Either<Failure, PaginatedListings>> searchListings(
    ListingSearchFilters filters,
  ) {
    return _guard(() async {
      final (items, meta) = await _remote.searchListings(filters);
      return PaginatedListings(
        items: items.map((m) => m.toEntity()).toList(),
        page: (meta?['page'] as num?)?.toInt() ?? filters.page,
        pageSize: (meta?['pageSize'] as num?)?.toInt() ?? 20,
        total: (meta?['total'] as num?)?.toInt() ?? items.length,
        totalPages: (meta?['totalPages'] as num?)?.toInt() ?? 1,
      );
    });
  }

  @override
  Future<Either<Failure, CropListingEntity>> getListing(String id) =>
      _guard(() async => (await _remote.getListing(id)).toEntity());

  @override
  Future<Either<Failure, CropListingEntity>> createListing(
    ListingDraft draft,
  ) => _guard(
    () async =>
        (await _remote.createListing(_draftToPayload(draft))).toEntity(),
  );

  @override
  Future<Either<Failure, CropListingEntity>> updateListing(
    String id,
    ListingDraft draft,
  ) => _guard(
    () async =>
        (await _remote.updateListing(id, _draftToPayload(draft))).toEntity(),
  );

  @override
  Future<Either<Failure, Unit>> deleteListing(String id) => _guard(() async {
    await _remote.deleteListing(id);
    return unit;
  });

  @override
  Future<Either<Failure, List<String>>> uploadImages(
    String listingId,
    List<MultipartFile> images,
  ) => _guard(() => _remote.uploadImages(listingId, images));

  @override
  Future<Either<Failure, String>> uploadVideo(
    String listingId,
    MultipartFile video,
  ) => _guard(() => _remote.uploadVideo(listingId, video));

  @override
  Future<Either<Failure, Unit>> reportListing(
    String listingId, {
    required String reason,
    String? details,
  }) => _guard(() async {
    await _remote.reportListing(listingId, reason: reason, details: details);
    return unit;
  });

  @override
  Future<Either<Failure, bool>> toggleBookmark(String listingId) =>
      _guard(() => _remote.toggleBookmark(listingId));

  @override
  Future<Either<Failure, List<CropListingEntity>>> getBookmarks() => _guard(
    () async =>
        (await _remote.getBookmarks()).map((m) => m.toEntity()).toList(),
  );
}

@Riverpod(keepAlive: true)
MarketplaceRepository marketplaceRepository(MarketplaceRepositoryRef ref) =>
    MarketplaceRepositoryImpl(ref.watch(marketplaceRemoteDataSourceProvider));
