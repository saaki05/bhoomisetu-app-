import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

part 'login_usecase.g.dart';

class LoginUseCase {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}

@riverpod
LoginUseCase loginUseCase(LoginUseCaseRef ref) => LoginUseCase(ref.watch(authRepositoryProvider));
