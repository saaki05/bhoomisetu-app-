import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/crop_listing_entity.dart';
import '../../domain/usecases/bookmark_usecases.dart';

part 'bookmarks_controller.g.dart';

@riverpod
class BookmarksController extends _$BookmarksController {
  @override
  Future<List<CropListingEntity>> build() async {
    final result = await ref.watch(getBookmarksUseCaseProvider).call();
    return result.fold((failure) => throw failure, (bookmarks) => bookmarks);
  }

  Future<bool> toggle(String listingId) async {
    final result = await ref.read(toggleBookmarkUseCaseProvider).call(listingId);
    return result.fold(
      (failure) => throw failure,
      (bookmarked) {
        ref.invalidateSelf();
        return bookmarked;
      },
    );
  }
}
