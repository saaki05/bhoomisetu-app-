import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/google_constants.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response_model.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local, this._secureStorage, this._localAuth);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final SecureStorageService _secureStorage;
  final LocalAuthentication _localAuth;
  bool _googleSignInInitialized = false;

  Future<Either<Failure, UserEntity>> _run(Future<AuthResponseModel> Function() call) async {
    try {
      final response = await call();
      await _local.saveSession(
        user: response.user,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return Right(response.user.toEntity());
    } on AppException catch (e) {
      return Left(failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String fullName,
    required String email,
    String? phone,
    required String password,
    required UserRole role,
  }) {
    return _run(() => _remote.register(
          fullName: fullName,
          email: email,
          phone: phone,
          password: password,
          role: role.apiValue,
        ));
  }

  @override
  Future<Either<Failure, UserEntity>> login({required String email, required String password}) {
    return _run(() => _remote.login(email: email, password: password));
  }

  @override
  Future<Either<Failure, Unit>> requestOtp({required String phone}) async {
    try {
      await _remote.requestOtp(phone: phone);
      return const Right(unit);
    } on AppException catch (e) {
      return Left(failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String phone,
    required String otp,
    String? fullName,
    UserRole? role,
  }) {
    return _run(() => _remote.verifyOtp(phone: phone, otp: otp, fullName: fullName, role: role?.apiValue));
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle({UserRole? role}) async {
    try {
      final googleSignIn = GoogleSignIn.instance;

      // initialize() must run before the first authenticate() call each
      // app session; serverClientId is the Web OAuth client that becomes
      // the ID token's audience, which is what Supabase's
      // signInWithIdToken checks against the Google provider it has
      // configured.
      if (!_googleSignInInitialized) {
        await googleSignIn.initialize(serverClientId: GoogleConstants.signInWebClientId);
        _googleSignInInitialized = true;
      }

      final account = await googleSignIn.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null) {
        return const Left(Failure.unknown('Could not retrieve Google credentials'));
      }

      return _run(() => _remote.signInWithGoogle(idToken: idToken, role: role?.apiValue));
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const Left(Failure.unknown('Google sign-in was cancelled'));
      }
      return Left(Failure.unknown(e.description ?? 'Google sign-in failed'));
    }
  }

  @override
  Future<Either<Failure, Unit>> forgotPassword({required String email}) async {
    try {
      await _remote.forgotPassword(email: email);
      return const Right(unit);
    } on AppException catch (e) {
      return Left(failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String recoveryAccessToken,
    required String newPassword,
  }) async {
    try {
      await _remote.resetPassword(recoveryAccessToken: recoveryAccessToken, newPassword: newPassword);
      return const Right(unit);
    } on AppException catch (e) {
      return Left(failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    final refreshToken = await _local.refreshToken;
    try {
      if (refreshToken != null) {
        await _remote.logout(refreshToken: refreshToken);
      }
    } on AppException {
      // Even if the server call fails (e.g. offline), still clear the
      // local session so the user isn't stuck logged in on-device.
    } finally {
      await _local.clearSession();
    }
    return const Right(unit);
  }

  @override
  Future<UserEntity?> restoreSession() async {
    if (!await _local.hasStoredSession) return null;
    return _local.cachedUser?.toEntity();
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await _remote.me();
      await _local.updateCachedUser(user);
      return Right(user.toEntity());
    } on AppException catch (e) {
      return Left(failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> selectRole(UserRole role) async {
    try {
      final user = await _remote.selectRole(role.apiValue);
      await _local.updateCachedUser(user);
      return Right(user.toEntity());
    } on AppException catch (e) {
      return Left(failureFromException(e));
    }
  }

  @override
  Future<bool> get isBiometricAvailable async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> get isBiometricLoginEnabled => _secureStorage.isBiometricEnabled;

  @override
  Future<void> setBiometricLoginEnabled(bool enabled) => _secureStorage.setBiometricEnabled(enabled);

  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to log in to BhoomiSetu',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } on PlatformException {
      return false;
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) => AuthRepositoryImpl(
      ref.watch(authRemoteDataSourceProvider),
      ref.watch(authLocalDataSourceProvider),
      ref.watch(secureStorageServiceProvider),
      LocalAuthentication(),
    );
