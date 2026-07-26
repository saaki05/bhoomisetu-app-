import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/crop_listing_entity.dart';
import '../../domain/usecases/listing_detail_usecases.dart';

part 'listing_detail_provider.g.dart';

@riverpod
Future<CropListingEntity> listingDetail(ListingDetailRef ref, String listingId) async {
  final result = await ref.watch(getListingUseCaseProvider).call(listingId);
  return result.fold((failure) => throw failure, (listing) => listing);
}
