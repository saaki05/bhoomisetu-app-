import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../data/repositories_impl/home_repository_impl.dart';
import '../entities/home_summary_entity.dart';
import '../repositories/home_repository.dart';

part 'get_home_summary_usecase.g.dart';

class GetHomeSummaryUseCase {
  GetHomeSummaryUseCase(this._repository);

  final HomeRepository _repository;

  Future<Either<Failure, HomeSummaryEntity>> call() => _repository.getSummary();
}

@riverpod
GetHomeSummaryUseCase getHomeSummaryUseCase(GetHomeSummaryUseCaseRef ref) =>
    GetHomeSummaryUseCase(ref.watch(homeRepositoryProvider));
