import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

part 'session_usecases.g.dart';

/// Restores a session from local storage only — no network call — so the
/// splash screen can decide its redirect target instantly.
class RestoreSessionUseCase {
  RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity?> call() => _repository.restoreSession();
}

/// Refetches the authoritative profile from the backend (role, verification
/// flags, rating). Used after restoring a session and periodically from the
/// profile screen.
class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call() => _repository.getCurrentUser();
}

@riverpod
RestoreSessionUseCase restoreSessionUseCase(RestoreSessionUseCaseRef ref) =>
    RestoreSessionUseCase(ref.watch(authRepositoryProvider));

@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(GetCurrentUserUseCaseRef ref) =>
    GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
