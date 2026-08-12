import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/location_service.dart';
import '../../domain/entities/home_summary_entity.dart';
import '../../domain/usecases/get_home_summary_usecase.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  Future<HomeSummaryEntity> build() async {
    return _loadSummary();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<HomeSummaryEntity>().copyWithPrevious(state);
    state = await AsyncValue.guard(_loadSummary);
  }

  Future<HomeSummaryEntity> _loadSummary() async {
    final position = await ref.read(locationServiceProvider).getCurrentPosition();
    final result = await ref
        .read(getHomeSummaryUseCaseProvider)
        .call(lat: position?.latitude, lon: position?.longitude);
    return result.fold((failure) => throw failure, (summary) {
      // Never tell a user they are in Delhi merely because GPS permission or
      // a fresh fix was unavailable. The backend's legacy Delhi forecast is
      // treated as absent unless this request carried real coordinates.
      final usedLegacyDefault =
          position == null && summary.weather?.location == 'New Delhi, India';
      return usedLegacyDefault ? summary.copyWith(weather: null) : summary;
    });
  }
}
