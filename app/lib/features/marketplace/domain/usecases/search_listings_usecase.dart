import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../data/repositories_impl/marketplace_repository_impl.dart';
import '../entities/crop_listing_entity.dart';
import '../entities/listing_search_filters.dart';
import '../repositories/marketplace_repository.dart';

part 'search_listings_usecase.g.dart';

class SearchListingsUseCase {
  SearchListingsUseCase(this._repository);

  final MarketplaceRepository _repository;

  Future<Either<Failure, PaginatedListings>> call(ListingSearchFilters filters) =>
      _repository.searchListings(filters);
}

@riverpod
SearchListingsUseCase searchListingsUseCase(SearchListingsUseCaseRef ref) =>
    SearchListingsUseCase(ref.watch(marketplaceRepositoryProvider));
