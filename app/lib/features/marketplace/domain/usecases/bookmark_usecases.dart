import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../data/repositories_impl/marketplace_repository_impl.dart';
import '../entities/crop_listing_entity.dart';
import '../repositories/marketplace_repository.dart';

part 'bookmark_usecases.g.dart';

class ToggleBookmarkUseCase {
  ToggleBookmarkUseCase(this._repository);

  final MarketplaceRepository _repository;

  Future<Either<Failure, bool>> call(String listingId) => _repository.toggleBookmark(listingId);
}

class GetBookmarksUseCase {
  GetBookmarksUseCase(this._repository);

  final MarketplaceRepository _repository;

  Future<Either<Failure, List<CropListingEntity>>> call() => _repository.getBookmarks();
}

class ReportListingUseCase {
  ReportListingUseCase(this._repository);

  final MarketplaceRepository _repository;

  Future<Either<Failure, Unit>> call(String listingId, {required String reason, String? details}) =>
      _repository.reportListing(listingId, reason: reason, details: details);
}

@riverpod
ToggleBookmarkUseCase toggleBookmarkUseCase(ToggleBookmarkUseCaseRef ref) =>
    ToggleBookmarkUseCase(ref.watch(marketplaceRepositoryProvider));

@riverpod
GetBookmarksUseCase getBookmarksUseCase(GetBookmarksUseCaseRef ref) =>
    GetBookmarksUseCase(ref.watch(marketplaceRepositoryProvider));

@riverpod
ReportListingUseCase reportListingUseCase(ReportListingUseCaseRef ref) =>
    ReportListingUseCase(ref.watch(marketplaceRepositoryProvider));
