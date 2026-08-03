import 'package:freezed_annotation/freezed_annotation.dart';

part 'crop_listing_entity.freezed.dart';

@freezed
abstract class ListingFarmer with _$ListingFarmer {
  const factory ListingFarmer({
    required String id,
    required String fullName,
    String? avatarUrl,
    required double avgRating,
    required int totalReviews,
    String? phone,
  }) = _ListingFarmer;
}

@freezed
abstract class CropListingEntity with _$CropListingEntity {
  const factory CropListingEntity({
    required String id,
    required String farmerId,
    required String categoryId,
    String? categoryName,
    required String title,
    String? description,
    required String status,
    required double pricePerUnit,
    required String unit,
    required double quantityAvailable,
    double? suggestedMarketPrice,
    required bool isOrganic,
    String? harvestDate,
    String? district,
    String? state,
    String? village,
    required double avgRating,
    required int totalReviews,
    required List<String> images,
    String? videoUrl,
    ListingFarmer? farmer,
    required String createdAt,
  }) = _CropListingEntity;
}

@freezed
abstract class PaginatedListings with _$PaginatedListings {
  const factory PaginatedListings({
    required List<CropListingEntity> items,
    required int page,
    required int pageSize,
    required int total,
    required int totalPages,
  }) = _PaginatedListings;
}
