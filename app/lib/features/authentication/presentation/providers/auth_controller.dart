import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/socket_client.dart';
import '../../../../core/services/session_expiry_notifier.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/otp_usecases.dart';
import '../../domain/usecases/password_reset_usecases.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/session_usecases.dart';

part 'auth_controller.g.dart';

/// Single source of truth for "who is logged in, if anyone". `null` data
/// means unauthenticated; any thrown [Failure] surfaces through
/// [AsyncValue.error] the same way every other controller in this app
/// reports failures, so [AsyncValueWidget] and the router redirect can
/// treat it uniformly.
@riverpod
class AuthController extends _$AuthController {
  StreamSubscription<void>? _sessionExpirySub;

  @override
  Future<UserEntity?> build() async {
    ref.onDispose(() => _sessionExpirySub?.cancel());
    _sessionExpirySub = ref.watch(sessionExpiryNotifierProvider).onSessionExpired.listen((_) {
      ref.read(socketClientProvider).disconnect();
      state = const AsyncData(null);
    });

    final cached = await ref.watch(restoreSessionUseCaseProvider).call();
    if (cached != null) {
      unawaited(_refreshFromServer());
      unawaited(ref.read(socketClientProvider).connect());
    }
    return cached;
  }

  Future<void> _refreshFromServer() async {
    final result = await ref.read(getCurrentUserUseCaseProvider).call();
    result.fold(
      (_) {}, // Keep the cached user if the background refresh fails (e.g. offline).
      (user) => state = AsyncData(user),
    );
  }

  Future<Failure?> login({required String email, required String password}) {
    return _submit(() => ref.read(loginUseCaseProvider).call(email: email, password: password));
  }

  Future<Failure?> register({
    required String fullName,
    required String email,
    String? phone,
    required String password,
    required UserRole role,
  }) {
    return _submit(() => ref.read(registerUseCaseProvider).call(
          fullName: fullName,
          email: email,
          phone: phone,
          password: password,
          role: role,
        ));
  }

  Future<Failure?> verifyOtp({
    required String phone,
    required String otp,
    String? fullName,
    UserRole? role,
  }) {
    return _submit(() => ref
        .read(verifyOtpUseCaseProvider)
        .call(phone: phone, otp: otp, fullName: fullName, role: role));
  }

  Future<Failure?> signInWithGoogle({UserRole? role}) {
    return _submit(() => ref.read(googleSignInUseCaseProvider).call(role: role));
  }

  /// These three don't authenticate anyone, so they report their own
  /// Either result to the caller instead of mutating [state].
  Future<Either<Failure, Unit>> requestOtp({required String phone}) {
    return ref.read(requestOtpUseCaseProvider).call(phone: phone);
  }

  Future<Either<Failure, Unit>> forgotPassword({required String email}) {
    return ref.read(forgotPasswordUseCaseProvider).call(email: email);
  }

  Future<Either<Failure, Unit>> resetPassword({required String recoveryAccessToken, required String newPassword}) {
    return ref
        .read(resetPasswordUseCaseProvider)
        .call(recoveryAccessToken: recoveryAccessToken, newPassword: newPassword);
  }

  Future<Failure?> _submit(Future<Either<Failure, UserEntity>> Function() action) async {
    state = const AsyncLoading<UserEntity?>().copyWithPrevious(state);
    final result = await action();
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return failure;
      },
      (user) {
        state = AsyncData(user);
        unawaited(ref.read(socketClientProvider).connect());
        return null;
      },
    );
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call();
    ref.read(socketClientProvider).disconnect();
    state = const AsyncData(null);
  }
}

/// Convenience read-only view for widgets that only need to know whether
/// someone is currently logged in (router redirects, gated app-bar actions).
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  return ref.watch(authControllerProvider).valueOrNull != null;
}
