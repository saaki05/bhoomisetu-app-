import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../data/repositories_impl/marketplace_repository_impl.dart';
import '../entities/category_entity.dart';
import '../repositories/marketplace_repository.dart';

part 'get_categories_usecase.g.dart';

class GetCategoriesUseCase {
  GetCategoriesUseCase(this._repository);

  final MarketplaceRepository _repository;

  Future<Either<Failure, List<CategoryEntity>>> call() => _repository.getCategories();
}

@riverpod
GetCategoriesUseCase getCategoriesUseCase(GetCategoriesUseCaseRef ref) =>
    GetCategoriesUseCase(ref.watch(marketplaceRepositoryProvider));
