import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../data/repositories_impl/auth_repository_impl.dart';
import '../entities/user_entity.dart';
import '../entities/user_role.dart';
import '../repositories/auth_repository.dart';

part 'otp_usecases.g.dart';

class RequestOtpUseCase {
  RequestOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call({required String phone}) => _repository.requestOtp(phone: phone);
}

class VerifyOtpUseCase {
  VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String phone,
    required String otp,
    String? fullName,
    UserRole? role,
  }) {
    return _repository.verifyOtp(phone: phone, otp: otp, fullName: fullName, role: role);
  }
}

@riverpod
RequestOtpUseCase requestOtpUseCase(RequestOtpUseCaseRef ref) => RequestOtpUseCase(ref.watch(authRepositoryProvider));

@riverpod
VerifyOtpUseCase verifyOtpUseCase(VerifyOtpUseCaseRef ref) => VerifyOtpUseCase(ref.watch(authRepositoryProvider));
