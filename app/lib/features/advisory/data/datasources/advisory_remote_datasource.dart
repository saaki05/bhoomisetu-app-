import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/advisory_message.dart';

part 'advisory_remote_datasource.g.dart';

class AdvisoryRemoteDataSource {
  AdvisoryRemoteDataSource(this._client);

  final ApiClient _client;

  Future<String> sendMessage({required String message, required List<AdvisoryMessage> history}) {
    return _client.post<String>(
      ApiConstants.advisoryChat,
      data: {
        'message': message,
        'history': history
            .map((turn) => {'role': turn.role == AdvisoryRole.user ? 'user' : 'assistant', 'content': turn.content})
            .toList(),
      },
      parser: (json) => (json as Map<String, dynamic>)['reply'] as String,
    );
  }
}

@Riverpod(keepAlive: true)
AdvisoryRemoteDataSource advisoryRemoteDataSource(AdvisoryRemoteDataSourceRef ref) =>
    AdvisoryRemoteDataSource(ref.watch(apiClientProvider));
