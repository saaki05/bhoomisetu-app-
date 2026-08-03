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

  Future<Either<Failure, CropListingEntity>> submit({
    required ListingDraft draft,
    required List<File> images,
    File? video,
  }) async {
    final createResult = await ref.read(createListingUseCaseProvider).call(draft);
    if (createResult.isLeft()) return Left((createResult as Left<Failure, CropListingEntity>).value);

    var listing = (createResult as Right<Failure, CropListingEntity>).value;
    if (images.isNotEmpty) {
      final multipartImages = await Future.wait(
        images.map((file) => MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last)),
      );
      final result = await ref.read(uploadListingImagesUseCaseProvider).call(listing.id, multipartImages);
      result.fold((_) {}, (urls) => listing = listing.copyWith(images: urls));
    }
    if (video != null) {
      final multipartVideo = await MultipartFile.fromFile(video.path, filename: video.uri.pathSegments.last);
      final result = await ref.read(uploadListingVideoUseCaseProvider).call(listing.id, multipartVideo);
      result.fold((_) {}, (url) => listing = listing.copyWith(videoUrl: url));
    }
    return Right(listing);
  }
}
