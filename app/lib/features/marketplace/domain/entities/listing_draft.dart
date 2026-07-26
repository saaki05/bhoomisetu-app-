import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing_draft.freezed.dart';

/// Input for creating/updating a listing — kept separate from
/// [CropListingEntity] since the server derives several read-only fields
/// (ratings, images, farmer summary) that a draft never carries.
@freezed
abstract class ListingDraft with _$ListingDraft {
  const factory ListingDraft({
    required String categoryId,
    String? farmId,
    required String title,
    String? description,
    required double pricePerUnit,
    @Default('quintal') String unit,
    required double quantityAvailable,
    double? suggestedMarketPrice,
    @Default(false) bool isOrganic,
    String? harvestDate,
    String? district,
    String? state,
    String? village,
    @Default('active') String status,
  }) = _ListingDraft;
}
