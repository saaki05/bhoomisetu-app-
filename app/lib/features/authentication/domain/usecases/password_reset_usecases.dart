import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../repositories/auth_repository.dart';

part 'password_reset_usecases.g.dart';

class ForgotPasswordUseCase {
  ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call({required String email}) => _repository.forgotPassword(email: email);
}

class ResetPasswordUseCase {
  ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call({required String recoveryAccessToken, required String newPassword}) {
    return _repository.resetPassword(recoveryAccessToken: recoveryAccessToken, newPassword: newPassword);
  }
}

@riverpod
ForgotPasswordUseCase forgotPasswordUseCase(ForgotPasswordUseCaseRef ref) =>
    ForgotPasswordUseCase(ref.watch(authRepositoryProvider));

@riverpod
ResetPasswordUseCase resetPasswordUseCase(ResetPasswordUseCaseRef ref) =>
    ResetPasswordUseCase(ref.watch(authRepositoryProvider));
