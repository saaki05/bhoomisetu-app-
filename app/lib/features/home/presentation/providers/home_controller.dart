import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/location_service.dart';
import '../../domain/entities/home_summary_entity.dart';
import '../../domain/usecases/get_home_summary_usecase.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  Future<HomeSummaryEntity> build() async {
    final position = await ref.watch(locationServiceProvider).getCurrentPosition();
    final result = await ref
        .watch(getHomeSummaryUseCaseProvider)
        .call(lat: position?.latitude, lon: position?.longitude);
    return result.fold((failure) => throw failure, (summary) => summary);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<HomeSummaryEntity>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final position = await ref.read(locationServiceProvider).getCurrentPosition();
      final result = await ref
          .read(getHomeSummaryUseCaseProvider)
          .call(lat: position?.latitude, lon: position?.longitude);
      return result.fold((failure) => throw failure, (summary) => summary);
    });
  }
}
