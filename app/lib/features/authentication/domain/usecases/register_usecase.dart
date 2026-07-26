import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../entities/user_entity.dart';
import '../entities/user_role.dart';
import '../repositories/auth_repository.dart';

part 'register_usecase.g.dart';

class RegisterUseCase {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String fullName,
    required String email,
    String? phone,
    required String password,
    required UserRole role,
  }) {
    return _repository.register(fullName: fullName, email: email, phone: phone, password: password, role: role);
  }
}

@riverpod
RegisterUseCase registerUseCase(RegisterUseCaseRef ref) => RegisterUseCase(ref.watch(authRepositoryProvider));
