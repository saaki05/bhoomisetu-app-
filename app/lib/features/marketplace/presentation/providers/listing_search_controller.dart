import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/crop_listing_entity.dart';
import '../../domain/entities/listing_search_filters.dart';
import '../../domain/usecases/search_listings_usecase.dart';

part 'listing_search_controller.freezed.dart';
part 'listing_search_controller.g.dart';

@freezed
abstract class ListingSearchState with _$ListingSearchState {
  const factory ListingSearchState({
    required ListingSearchFilters filters,
    required List<CropListingEntity> items,
    required int page,
    required int totalPages,
    @Default(false) bool isLoadingMore,
  }) = _ListingSearchState;
}

@riverpod
class ListingSearchController extends _$ListingSearchController {
  @override
  Future<ListingSearchState> build() => _fetch(const ListingSearchFilters());

  Future<ListingSearchState> _fetch(ListingSearchFilters filters) async {
    final result = await ref.watch(searchListingsUseCaseProvider).call(filters);
    return result.fold(
      (failure) => throw failure,
      (paginated) => ListingSearchState(
        filters: filters,
        items: paginated.items,
        page: paginated.page,
        totalPages: paginated.totalPages,
      ),
    );
  }

  Future<void> _applyFilters(ListingSearchFilters Function(ListingSearchFilters current) update) async {
    final current = state.valueOrNull?.filters ?? const ListingSearchFilters();
    state = const AsyncLoading<ListingSearchState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(update(current).copyWith(page: 1)));
  }

  Future<void> setQuery(String query) => _applyFilters((f) => f.copyWith(query: query.isEmpty ? null : query));

  Future<void> setCategory(String? categoryId) => _applyFilters((f) => f.copyWith(categoryId: categoryId));

  Future<void> setSort(ListingSortOption sort) => _applyFilters((f) => f.copyWith(sortBy: sort));

  Future<void> setOrganicOnly(bool organicOnly) =>
      _applyFilters((f) => f.copyWith(organicOnly: organicOnly ? true : null));

  Future<void> setPriceRange({double? minPrice, double? maxPrice}) =>
      _applyFilters((f) => f.copyWith(minPrice: minPrice, maxPrice: maxPrice));

  Future<void> clearFilters() => _applyFilters((_) => const ListingSearchFilters());

  Future<void> refresh() async {
    final filters = state.valueOrNull?.filters ?? const ListingSearchFilters();
    state = await AsyncValue.guard(() => _fetch(filters.copyWith(page: 1)));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || current.page >= current.totalPages) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextFilters = current.filters.copyWith(page: current.page + 1);
    final result = await ref.read(searchListingsUseCaseProvider).call(nextFilters);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (paginated) => AsyncData(current.copyWith(
        items: [...current.items, ...paginated.items],
        page: paginated.page,
        totalPages: paginated.totalPages,
        isLoadingMore: false,
      )),
    );
  }
}
