import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing_search_filters.freezed.dart';

enum ListingSortOption { newest, priceAsc, priceDesc, rating }

extension ListingSortOptionApi on ListingSortOption {
  String get apiValue => switch (this) {
        ListingSortOption.newest => 'newest',
        ListingSortOption.priceAsc => 'price_asc',
        ListingSortOption.priceDesc => 'price_desc',
        ListingSortOption.rating => 'rating',
      };

  String get label => switch (this) {
        ListingSortOption.newest => 'Newest',
        ListingSortOption.priceAsc => 'Price: Low to High',
        ListingSortOption.priceDesc => 'Price: High to Low',
        ListingSortOption.rating => 'Top Rated',
      };
}

@freezed
abstract class ListingSearchFilters with _$ListingSearchFilters {
  const factory ListingSearchFilters({
    String? query,
    String? categoryId,
    String? district,
    String? state,
    bool? organicOnly,
    double? minPrice,
    double? maxPrice,
    @Default(ListingSortOption.newest) ListingSortOption sortBy,
    @Default(1) int page,
  }) = _ListingSearchFilters;
}
