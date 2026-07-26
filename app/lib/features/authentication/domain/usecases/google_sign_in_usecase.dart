import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../entities/user_entity.dart';
import '../entities/user_role.dart';
import '../repositories/auth_repository.dart';

part 'google_sign_in_usecase.g.dart';

class GoogleSignInUseCase {
  GoogleSignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({UserRole? role}) => _repository.signInWithGoogle(role: role);
}

@riverpod
GoogleSignInUseCase googleSignInUseCase(GoogleSignInUseCaseRef ref) =>
    GoogleSignInUseCase(ref.watch(authRepositoryProvider));
