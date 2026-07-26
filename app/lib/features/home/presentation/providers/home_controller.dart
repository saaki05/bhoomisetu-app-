import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/home_summary_entity.dart';
import '../../domain/usecases/get_home_summary_usecase.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  Future<HomeSummaryEntity> build() async {
    final result = await ref.watch(getHomeSummaryUseCaseProvider).call();
    return result.fold((failure) => throw failure, (summary) => summary);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<HomeSummaryEntity>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final result = await ref.read(getHomeSummaryUseCaseProvider).call();
      return result.fold((failure) => throw failure, (summary) => summary);
    });
  }
}
