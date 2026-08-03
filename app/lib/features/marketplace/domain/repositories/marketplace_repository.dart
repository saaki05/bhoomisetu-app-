import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' show MultipartFile;

import '../../../../core/exceptions/failure.dart';
import '../entities/category_entity.dart';
import '../entities/crop_listing_entity.dart';
import '../entities/listing_draft.dart';
import '../entities/listing_search_filters.dart';

abstract class MarketplaceRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, PaginatedListings>> searchListings(ListingSearchFilters filters);

  Future<Either<Failure, CropListingEntity>> getListing(String id);

  Future<Either<Failure, CropListingEntity>> createListing(ListingDraft draft);

  Future<Either<Failure, CropListingEntity>> updateListing(String id, ListingDraft draft);

  Future<Either<Failure, Unit>> deleteListing(String id);

  Future<Either<Failure, List<String>>> uploadImages(String listingId, List<MultipartFile> images);

  Future<Either<Failure, String>> uploadVideo(String listingId, MultipartFile video);

  Future<Either<Failure, Unit>> reportListing(String listingId, {required String reason, String? details});

  Future<Either<Failure, bool>> toggleBookmark(String listingId);

  Future<Either<Failure, List<CropListingEntity>>> getBookmarks();
}
