import 'package:bhoomisetu/core/exceptions/app_exception.dart';
import 'package:bhoomisetu/core/exceptions/failure.dart';
import 'package:bhoomisetu/core/storage/secure_storage_service.dart';
import 'package:bhoomisetu/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:bhoomisetu/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:bhoomisetu/features/authentication/data/models/auth_response_model.dart';
import 'package:bhoomisetu/features/authentication/data/models/user_model.dart';
import 'package:bhoomisetu/features/authentication/data/repositories_impl/auth_repository_impl.dart';
import 'package:bhoomisetu/features/authentication/domain/entities/user_role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class _MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class _MockSecureStorageService extends Mock implements SecureStorageService {}

class _MockLocalAuthentication extends Mock implements LocalAuthentication {}

UserModel _buildUserModel({String role = 'farmer'}) => UserModel(
      id: 'user-1',
      role: role,
      fullName: 'Test Farmer',
      email: 'farmer@example.com',
      phone: null,
      avatarUrl: null,
      village: null,
      district: null,
      state: null,
      isPhoneVerified: false,
      isEmailVerified: true,
      avgRating: 0,
      totalReviews: 0,
    );

void main() {
  late _MockAuthRemoteDataSource remote;
  late _MockAuthLocalDataSource local;
  late _MockSecureStorageService secureStorage;
  late _MockLocalAuthentication localAuth;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_buildUserModel());
  });

  setUp(() {
    remote = _MockAuthRemoteDataSource();
    local = _MockAuthLocalDataSource();
    secureStorage = _MockSecureStorageService();
    localAuth = _MockLocalAuthentication();
    repository = AuthRepositoryImpl(remote, local, secureStorage, localAuth);

    when(() => local.saveSession(
          user: any(named: 'user'),
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        )).thenAnswer((_) async {});
  });

  group('login', () {
    test('persists the session and returns the mapped entity on success', () async {
      final userModel = _buildUserModel();
      when(() => remote.login(email: 'farmer@example.com', password: 'Passw0rd1')).thenAnswer(
        (_) async => AuthResponseModel(user: userModel, accessToken: 'access', refreshToken: 'refresh'),
      );

      final result = await repository.login(email: 'farmer@example.com', password: 'Passw0rd1');

      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (user) {
        expect(user.id, 'user-1');
        expect(user.role, UserRole.farmer);
      });
      verify(() => local.saveSession(user: userModel, accessToken: 'access', refreshToken: 'refresh')).called(1);
    });

    test('maps an UnauthorizedException to Failure.unauthorized', () async {
      when(() => remote.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(const UnauthorizedException('Invalid email or password'));

      final result = await repository.login(email: 'farmer@example.com', password: 'wrong');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('expected Left'),
      );
      verifyNever(() => local.saveSession(
            user: any(named: 'user'),
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ));
    });

    test('maps a NetworkException to Failure.network', () async {
      when(() => remote.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(const NetworkException());

      final result = await repository.login(email: 'farmer@example.com', password: 'Passw0rd1');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('logout', () {
    test('revokes the refresh token remotely and always clears local session', () async {
      when(() => local.refreshToken).thenAnswer((_) async => 'refresh-token');
      when(() => remote.logout(refreshToken: 'refresh-token')).thenAnswer((_) async {});
      when(() => local.clearSession()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result.isRight(), isTrue);
      verify(() => remote.logout(refreshToken: 'refresh-token')).called(1);
      verify(() => local.clearSession()).called(1);
    });

    test('still clears local session even if the remote call fails', () async {
      when(() => local.refreshToken).thenAnswer((_) async => 'refresh-token');
      when(() => remote.logout(refreshToken: 'refresh-token')).thenThrow(const NetworkException());
      when(() => local.clearSession()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result.isRight(), isTrue);
      verify(() => local.clearSession()).called(1);
    });
  });

  group('restoreSession', () {
    test('returns null when there is no stored session', () async {
      when(() => local.hasStoredSession).thenAnswer((_) async => false);

      final user = await repository.restoreSession();

      expect(user, isNull);
    });

    test('returns the cached user when a session is stored', () async {
      when(() => local.hasStoredSession).thenAnswer((_) async => true);
      when(() => local.cachedUser).thenReturn(_buildUserModel(role: 'buyer'));

      final user = await repository.restoreSession();

      expect(user, isNotNull);
      expect(user!.role, UserRole.buyer);
    });
  });

  group('biometric preference', () {
    test('isBiometricLoginEnabled delegates to secure storage', () async {
      when(() => secureStorage.isBiometricEnabled).thenAnswer((_) async => true);

      expect(await repository.isBiometricLoginEnabled, isTrue);
    });

    test('setBiometricLoginEnabled delegates to secure storage', () async {
      when(() => secureStorage.setBiometricEnabled(true)).thenAnswer((_) async {});

      await repository.setBiometricLoginEnabled(true);

      verify(() => secureStorage.setBiometricEnabled(true)).called(1);
    });
  });
}
