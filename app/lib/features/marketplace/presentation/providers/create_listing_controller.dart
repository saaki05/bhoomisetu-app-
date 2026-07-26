import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../domain/entities/crop_listing_entity.dart';
import '../../domain/entities/listing_draft.dart';
import '../../domain/usecases/listing_detail_usecases.dart';

part 'create_listing_controller.g.dart';

@riverpod
class CreateListingController extends _$CreateListingController {
  @override
  void build() {}

  /// Creates the listing, then uploads any picked images against the new
  /// listing's id. If image upload fails after a successful create, the
  /// listing itself still exists (as a valid, if photo-less, draft) — the
  /// caller can retry uploading from the edit screen.
  Future<Either<Failure, CropListingEntity>> submit({
    required ListingDraft draft,
    required List<File> images,
  }) async {
    final createResult = await ref.read(createListingUseCaseProvider).call(draft);
    if (createResult.isLeft()) {
      return Left((createResult as Left<Failure, CropListingEntity>).value);
    }
    final listing = (createResult as Right<Failure, CropListingEntity>).value;

    if (images.isEmpty) return Right(listing);

    final multipartImages = await Future.wait(
      images.map((file) => MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last)),
    );
    final uploadResult = await ref.read(uploadListingImagesUseCaseProvider).call(listing.id, multipartImages);

    // The listing itself was created successfully either way; if the image
    // upload fails, surface the listing without images rather than losing
    // it — the caller can retry uploads from the edit screen.
    return uploadResult.fold(
      (_) => Right(listing),
      (imageUrls) => Right(listing.copyWith(images: imageUrls)),
    );
  }
}
