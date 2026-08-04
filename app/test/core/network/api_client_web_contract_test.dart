import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bhoomisetu/core/network/api_client.dart';

void main() {
  late Dio dio;
  late ApiClient client;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    client = ApiClient(dio);
  });

  test('unwraps a browser-style map with non-String generic keys', () async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: <dynamic, dynamic>{
              'success': true,
              'data': <dynamic, dynamic>{'name': 'Tomato'},
            },
          ),
        ),
      ),
    );

    final result = await client.get<String>(
      '/listing',
      parser: (json) =>
          Map<String, dynamic>.from(json as Map)['name'] as String,
    );

    expect(result, 'Tomato');
  });

  test('normalizes pagination metadata from a browser-style map', () async {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: <dynamic, dynamic>{
              'success': true,
              'data': <dynamic>[],
              'meta': <dynamic, dynamic>{'page': 1.0, 'totalPages': 0.0},
            },
          ),
        ),
      ),
    );

    final (items, meta) = await client.getWithMeta<List<dynamic>>(
      '/listings',
      parser: (json) => List<dynamic>.from(json as List),
    );

    expect(items, isEmpty);
    expect((meta?['page'] as num).toInt(), 1);
    expect((meta?['totalPages'] as num).toInt(), 0);
  });
}
