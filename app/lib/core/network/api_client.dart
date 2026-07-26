import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../exceptions/app_exception.dart';
import 'dio_client.dart';

part 'api_client.g.dart';

/// Thin, typed wrapper around [Dio] used by every remote data source.
/// Centralizes response unwrapping (the backend always replies with
/// `{ success, message, data, ... }`) and translates [DioException]s into
/// the [AppException] hierarchy the domain layer understands.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
    bool skipAuth = false,
  }) =>
      _request<T>(
        () => _dio.get(path, queryParameters: queryParameters, options: _options(skipAuth)),
        parser,
      );

  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? parser,
    bool skipAuth = false,
  }) =>
      _request<T>(
        () => _dio.post(path, data: data, options: _options(skipAuth)),
        parser,
      );

  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? parser,
    bool skipAuth = false,
  }) =>
      _request<T>(
        () => _dio.put(path, data: data, options: _options(skipAuth)),
        parser,
      );

  Future<T> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? parser,
    bool skipAuth = false,
  }) =>
      _request<T>(
        () => _dio.patch(path, data: data, options: _options(skipAuth)),
        parser,
      );

  Future<T> delete<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? parser,
    bool skipAuth = false,
  }) =>
      _request<T>(
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
      final response = await _dio.get(path, queryParameters: queryParameters, options: _options(skipAuth));
      final body = response.data;
      final payload = body is Map<String, dynamic> ? body['data'] : body;
      final meta = body is Map<String, dynamic> ? body['meta'] as Map<String, dynamic>? : null;
      return (parser(payload), meta);
    } on DioException catch (error) {
      throw _mapDioException(error);
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
      final payload = body is Map<String, dynamic> ? body['data'] : body;
      if (parser != null) return parser(payload);
      return payload as T;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  AppException _mapDioException(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const NetworkException();
    }

    final response = error.response;
    if (response == null) {
      return UnknownException(error.message ?? 'Something went wrong');
    }

    final body = response.data;
    final message = (body is Map<String, dynamic> ? body['message'] as String? : null) ??
        'Something went wrong';
    final code = body is Map<String, dynamic> ? body['code'] as String? : null;

    if (response.statusCode == 401) {
      return UnauthorizedException(message);
    }
    if (response.statusCode == 400 && code == 'VALIDATION_ERROR') {
      final details = body is Map<String, dynamic> ? body['details'] : null;
      return ValidationException(message, fieldErrors: _extractFieldErrors(details));
    }
    if (response.statusCode == 403) {
      return PermissionException(message);
    }

    return ServerException(message, code: code, statusCode: response.statusCode);
  }

  Map<String, String>? _extractFieldErrors(dynamic details) {
    if (details is! Map) return null;
    final fieldErrors = details['fieldErrors'];
    if (fieldErrors is! Map) return null;
    return fieldErrors.map((key, value) {
      final firstMessage = value is List && value.isNotEmpty ? value.first.toString() : value.toString();
      return MapEntry(key.toString(), firstMessage);
    });
  }
}

@Riverpod(keepAlive: true)
ApiClient apiClient(ApiClientRef ref) => ApiClient(ref.watch(dioProvider));
