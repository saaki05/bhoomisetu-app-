import 'package:dio/dio.dart';

import '../../constants/api_constants.dart';
import '../../services/session_expiry_notifier.dart';
import '../../storage/secure_storage_service.dart';

/// Attaches the bearer access token to every request and transparently
/// refreshes it on a 401 response, retrying the original request exactly
/// once. Uses a request-locking [Completer] so concurrent 401s only trigger
/// a single refresh call instead of a stampede.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.secureStorage,
    required this.sessionExpiryNotifier,
    required this.refreshDio,
  });

  final SecureStorageService secureStorage;
  final SessionExpiryNotifier sessionExpiryNotifier;
  final Dio refreshDio;

  Future<String?>? _refreshInFlight;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra['skipAuth'] != true) {
      final token = await secureStorage.accessToken;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;
    final isAuthEndpoint = err.requestOptions.path.contains('/auth/');

    if (!isUnauthorized || alreadyRetried || isAuthEndpoint) {
      return handler.next(err);
    }

    final newAccessToken = await _refreshAccessToken();
    if (newAccessToken == null) {
      sessionExpiryNotifier.notifySessionExpired();
      return handler.next(err);
    }

    final retryOptions = err.requestOptions
      ..headers['Authorization'] = 'Bearer $newAccessToken'
      ..extra['retried'] = true;

    try {
      final response = await refreshDio.fetch(retryOptions);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  Future<String?> _refreshAccessToken() {
    // Coalesce concurrent refresh attempts into a single in-flight request.
    return _refreshInFlight ??= _performRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await secureStorage.refreshToken;
    if (refreshToken == null) return null;

    try {
      final response = await refreshDio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(extra: {'skipAuth': true}),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String;

      await secureStorage.saveTokens(accessToken: newAccessToken, refreshToken: newRefreshToken);
      return newAccessToken;
    } on DioException {
      await secureStorage.clearTokens();
      return null;
    }
  }
}
