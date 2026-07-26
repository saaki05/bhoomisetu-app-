import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/api_constants.dart';
import '../services/session_expiry_notifier.dart';
import '../storage/secure_storage_service.dart';
import 'interceptors/auth_interceptor.dart';

part 'dio_client.g.dart';

BaseOptions _baseOptions() => BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      contentType: 'application/json',
      headers: const {'Accept': 'application/json'},
    );

/// A bare Dio instance with no interceptors, used exclusively for token
/// refresh calls so the refresh request can never itself trigger the
/// auth interceptor's refresh logic (which would recurse).
@Riverpod(keepAlive: true)
Dio refreshDio(RefreshDioRef ref) => Dio(_baseOptions());

/// The primary Dio instance used by every remote data source. Carries the
/// auth interceptor (token attach + refresh-and-retry) and, in debug
/// builds, verbose request/response logging.
@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  final dio = Dio(_baseOptions());

  dio.interceptors.add(AuthInterceptor(
    secureStorage: ref.watch(secureStorageServiceProvider),
    sessionExpiryNotifier: ref.watch(sessionExpiryNotifierProvider),
    refreshDio: ref.watch(refreshDioProvider),
  ));

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint('[Dio] $obj'),
    ));
  }

  return dio;
}
