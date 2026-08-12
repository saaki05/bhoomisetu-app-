import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/exceptions/failure.dart';
import '../../domain/entities/advisory_message.dart';
import '../../domain/repositories/advisory_repository.dart';
import '../datasources/advisory_remote_datasource.dart';

part 'advisory_repository_impl.g.dart';

class AdvisoryRepositoryImpl implements AdvisoryRepository {
  AdvisoryRepositoryImpl(this._remote);

  final AdvisoryRemoteDataSource _remote;

  @override
  Future<Either<Failure, String>> sendMessage({required String message, required List<AdvisoryMessage> history}) async {
    try {
      final reply = await _remote.sendMessage(message: message, history: history);
      return Right(reply);
    } on AppException catch (e) {
      return Left(failureFromException(e));
    }
  }
}

@Riverpod(keepAlive: true)
AdvisoryRepository advisoryRepository(AdvisoryRepositoryRef ref) =>
    AdvisoryRepositoryImpl(ref.watch(advisoryRemoteDataSourceProvider));
