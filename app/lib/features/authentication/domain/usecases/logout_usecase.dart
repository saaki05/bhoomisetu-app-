import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../repositories/auth_repository.dart';

part 'logout_usecase.g.dart';

class LogoutUseCase {
  LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call() => _repository.logout();
}

@riverpod
LogoutUseCase logoutUseCase(LogoutUseCaseRef ref) => LogoutUseCase(ref.watch(authRepositoryProvider));
