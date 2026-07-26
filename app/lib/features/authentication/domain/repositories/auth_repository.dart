import 'package:dartz/dartz.dart';

import '../../../../core/exceptions/failure.dart';
import '../entities/user_entity.dart';
import '../entities/user_role.dart';

/// Contract the presentation layer depends on. The implementation (in
/// `data/repositories_impl`) is the only place that knows about Dio, the
/// backend's JSON shape, or where tokens get persisted.
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String email,
    String? phone,
    required String password,
    required UserRole role,
  });

  Future<Either<Failure, UserEntity>> login({required String email, required String password});

  Future<Either<Failure, Unit>> requestOtp({required String phone});

  Future<Either<Failure, UserEntity>> verifyOtp({
    required String phone,
    required String otp,
    String? fullName,
    UserRole? role,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle({UserRole? role});

  Future<Either<Failure, Unit>> forgotPassword({required String email});

  Future<Either<Failure, Unit>> resetPassword({required String recoveryAccessToken, required String newPassword});

  Future<Either<Failure, Unit>> logout();

  /// Resolves the current session from persisted tokens without hitting the
  /// network — used by the router/splash to decide the initial route.
  Future<UserEntity?> restoreSession();

  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Sets the account type for a user who signed up via Google/OTP without
  /// picking one. Fails if a role has already been explicitly chosen.
  Future<Either<Failure, UserEntity>> selectRole(UserRole role);

  /// Whether this device has usable biometric hardware with at least one
  /// fingerprint/face enrolled — gates whether the "Use biometric login"
  /// toggle is even shown.
  Future<bool> get isBiometricAvailable;

  /// The user's stored preference (distinct from device capability).
  Future<bool> get isBiometricLoginEnabled;

  Future<void> setBiometricLoginEnabled(bool enabled);

  /// Triggers the OS biometric prompt. Returns true only on a successful
  /// match; never throws for a user cancellation or a failed match.
  Future<bool> authenticateWithBiometrics();
}
