import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/api_constants.dart';
import '../exceptions/app_exception.dart';
import 'dio_client.dart';

part 'api_client.g.dart';

/// Thin, typed wrapper around [Dio] used by every remote data source.
/// Centralizes response unwrapping (the backend always replies with
/// `{ success, message, data, ... }`) and translates [DioException]s into
/// the [AppException] hierarchy the domain layer understands.
class ApiClient {
  ApiClient(
    this._dio, {
    this.backendRetryBaseDelay = const Duration(seconds: 2),
  });

  final Dio _dio;
  final Duration backendRetryBaseDelay;

  /// Wakes and verifies the hosted API before a non-idempotent operation.
  ///
  /// Render and its Redis service may resume independently after an idle
  /// period. A short-lived 5xx/connection reset during that window must not
  /// be allowed to consume a registration request. Calling this before auth
  /// writes makes the subsequent POST reliable without retrying the POST and
  /// risking a duplicate account.
  Future<void> ensureBackendReady() async {
    DioException? lastError;

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await _dio.get(ApiConstants.health, options: _options(true));
        return;
      } on DioException catch (error) {
        lastError = error;
        final statusCode = error.response?.statusCode;
        final isTransient = statusCode == null || statusCode >= 500;
        if (!isTransient || attempt == 2) {
          throw _mapDioException(error);
        }
        await Future<void>.delayed(backendRetryBaseDelay * (attempt + 1));
      }
    }

    throw _mapDioException(lastError!);
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
    bool skipAuth = false,
  }) => _request<T>(
    () => _dio.get(
      path,
      queryParameters: queryParameters,
      options: _options(skipAuth),
    ),
    parser,
  );

  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? parser,
    bool skipAuth = false,
  }) => _request<T>(
    () => _dio.post(path, data: data, options: _options(skipAuth)),
    parser,
  );

  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? parser,
    bool skipAuth = false,
  }) => _request<T>(
    () => _dio.put(path, data: data, options: _options(skipAuth)),
    parser,
  );

  Future<T> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? parser,
    bool skipAuth = false,
  }) => _request<T>(
    () => _dio.patch(path, data: data, options: _options(skipAuth)),
    parser,
  );

  Future<T> delete<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? parser,
    bool skipAuth = false,
  }) => _request<T>(
    () => _dio.delete(path, data: data, options: _options(skipAuth)),
    parser,
  );

  /// Like [get], but also returns the response envelope's `meta` object —
  /// used for paginated endpoints (`{ data: [...], meta: { page, total } }`).
  Future<(T data, Map<String, dynamic>? meta)> getWithMeta<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) parser,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: _options(skipAuth),
      );
      final body = response.data;
      final envelope = _asStringKeyedMap(body);
      final payload = envelope?['data'] ?? body;
      final meta = _asStringKeyedMap(envelope?['meta']);
      return (parser(payload), meta);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on AppException {
      rethrow;
    } catch (error) {
      throw UnknownException(
        'Could not read the server response (${error.runtimeType})',
      );
    }
  }

  Options _options(bool skipAuth) => Options(extra: {'skipAuth': skipAuth});

  Future<T> _request<T>(
    Future<Response<dynamic>> Function() call,
    T Function(dynamic json)? parser,
  ) async {
    try {
      final response = await call();
      final body = response.data;
      final envelope = _asStringKeyedMap(body);
      final payload = envelope?['data'] ?? body;
      if (parser != null) return parser(payload);
      return payload as T;
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on AppException {
      rethrow;
    } catch (error) {
      throw UnknownException(
        'Could not read the server response (${error.runtimeType})',
      );
    }
  }

  AppException _mapDioException(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return const NetworkException(
        'Unable to reach the BhoomiSetu server. Check your connection and try again.',
      );
    }
    if (error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const NetworkException(
        'The BhoomiSetu server is taking too long to respond. Please try again.',
      );
    }

    final response = error.response;
    if (response == null) {
      return UnknownException(error.message ?? 'Something went wrong');
    }

    final body = _asStringKeyedMap(response.data);
    final message = body?['message'] as String? ?? 'Something went wrong';
    final code = body?['code'] as String?;

    if (response.statusCode == 401) {
      return UnauthorizedException(message);
    }
    if (response.statusCode == 400 && code == 'VALIDATION_ERROR') {
      final details = body?['details'];
      return ValidationException(
        message,
        fieldErrors: _extractFieldErrors(details),
      );
    }
    if (response.statusCode == 403) {
      return PermissionException(message);
    }

    return ServerException(
      message,
      code: code,
      statusCode: response.statusCode,
    );
  }

  Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
    if (value is! Map) return null;
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  Map<String, String>? _extractFieldErrors(dynamic details) {
    if (details is! Map) return null;
    final fieldErrors = details['fieldErrors'];
    if (fieldErrors is! Map) return null;
    return fieldErrors.map((key, value) {
      final firstMessage = value is List && value.isNotEmpty
          ? value.first.toString()
          : value.toString();
      return MapEntry(key.toString(), firstMessage);
    });
  }
}

@Riverpod(keepAlive: true)
ApiClient apiClient(ApiClientRef ref) => ApiClient(ref.watch(dioProvider));
