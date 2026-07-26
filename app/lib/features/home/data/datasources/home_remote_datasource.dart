import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/home_summary_model.dart';

part 'home_remote_datasource.g.dart';

class HomeRemoteDataSource {
  HomeRemoteDataSource(this._client);

  final ApiClient _client;

  Future<HomeSummaryModel> getSummary() {
    return _client.get<HomeSummaryModel>(
      ApiConstants.homeSummary,
      parser: (json) => HomeSummaryModel.fromJson(json as Map<String, dynamic>),
    );
  }
}

@Riverpod(keepAlive: true)
HomeRemoteDataSource homeRemoteDataSource(HomeRemoteDataSourceRef ref) =>
    HomeRemoteDataSource(ref.watch(apiClientProvider));
