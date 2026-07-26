import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../domain/entities/home_summary_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/home_summary_model.dart';

part 'home_repository_impl.g.dart';

const _homeSummaryCacheKey = 'home.summary';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remote, this._cache);

  final HomeRemoteDataSource _remote;
  final LocalCacheService _cache;

  @override
  Future<Either<Failure, HomeSummaryEntity>> getSummary() async {
    try {
      final model = await _remote.getSummary();
      await _cache.putJson(_homeSummaryCacheKey, model.toJson());
      return Right(model.toEntity());
    } on AppException catch (e) {
      if (e is NetworkException) {
        final cached = _cache.getJson(_homeSummaryCacheKey);
        if (cached != null) {
          return Right(HomeSummaryModel.fromJson(cached).toEntity());
        }
      }
      return Left(failureFromException(e));
    }
  }
}

@Riverpod(keepAlive: true)
HomeRepository homeRepository(HomeRepositoryRef ref) => HomeRepositoryImpl(
      ref.watch(homeRemoteDataSourceProvider),
      ref.watch(localCacheServiceProvider),
    );
