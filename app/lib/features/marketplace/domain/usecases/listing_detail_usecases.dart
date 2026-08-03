import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' show MultipartFile;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../data/repositories_impl/marketplace_repository_impl.dart';
import '../entities/crop_listing_entity.dart';
import '../entities/listing_draft.dart';
import '../repositories/marketplace_repository.dart';

part 'listing_detail_usecases.g.dart';

class GetListingUseCase {
  GetListingUseCase(this._repository);

  final MarketplaceRepository _repository;

  Future<Either<Failure, CropListingEntity>> call(String id) => _repository.getListing(id);
}

class CreateListingUseCase {
  CreateListingUseCase(this._repository);

  final MarketplaceRepository _repository;

  Future<Either<Failure, CropListingEntity>> call(ListingDraft draft) => _repository.createListing(draft);
}

class UpdateListingUseCase {
  UpdateListingUseCase(this._repository);

  final MarketplaceRepository _repository;

  Future<Either<Failure, CropListingEntity>> call(String id, ListingDraft draft) =>
      _repository.updateListing(id, draft);
}

class DeleteListingUseCase {
  DeleteListingUseCase(this._repository);

  final MarketplaceRepository _repository;

  Future<Either<Failure, Unit>> call(String id) => _repository.deleteListing(id);
}

class UploadListingImagesUseCase {
  UploadListingImagesUseCase(this._repository);

  final MarketplaceRepository _repository;

  Future<Either<Failure, List<String>>> call(String listingId, List<MultipartFile> images) =>
      _repository.uploadImages(listingId, images);
}

class UploadListingVideoUseCase {
  UploadListingVideoUseCase(this._repository);

  final MarketplaceRepository _repository;

  Future<Either<Failure, String>> call(String listingId, MultipartFile video) =>
      _repository.uploadVideo(listingId, video);
}

@riverpod
GetListingUseCase getListingUseCase(GetListingUseCaseRef ref) =>
    GetListingUseCase(ref.watch(marketplaceRepositoryProvider));

@riverpod
CreateListingUseCase createListingUseCase(CreateListingUseCaseRef ref) =>
    CreateListingUseCase(ref.watch(marketplaceRepositoryProvider));

@riverpod
UpdateListingUseCase updateListingUseCase(UpdateListingUseCaseRef ref) =>
    UpdateListingUseCase(ref.watch(marketplaceRepositoryProvider));

@riverpod
DeleteListingUseCase deleteListingUseCase(DeleteListingUseCaseRef ref) =>
    DeleteListingUseCase(ref.watch(marketplaceRepositoryProvider));

@riverpod
UploadListingImagesUseCase uploadListingImagesUseCase(UploadListingImagesUseCaseRef ref) =>
    UploadListingImagesUseCase(ref.watch(marketplaceRepositoryProvider));

@riverpod
UploadListingVideoUseCase uploadListingVideoUseCase(UploadListingVideoUseCaseRef ref) =>
    UploadListingVideoUseCase(ref.watch(marketplaceRepositoryProvider));
