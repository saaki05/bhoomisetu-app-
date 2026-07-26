import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/chat_models.dart';

part 'chat_remote_datasource.g.dart';

class ChatRemoteDataSource {
  ChatRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<ChatConversationModel>> listConversations() {
    return _client.get<List<ChatConversationModel>>(
      ApiConstants.conversations,
      parser: (json) =>
          (json as List).map((e) => ChatConversationModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ChatConversationModel> startConversation({required String otherUserId, String? listingId}) {
    return _client.post<ChatConversationModel>(
      ApiConstants.conversations,
      data: {'otherUserId': otherUserId, 'listingId': ?listingId},
      parser: (json) => ChatConversationModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<(List<ChatMessageModel> items, Map<String, dynamic>? meta)> listMessages(
    String conversationId, {
    int page = 1,
  }) {
    return _client.getWithMeta<List<ChatMessageModel>>(
      ApiConstants.conversationMessages(conversationId),
      queryParameters: {'page': page},
      parser: (json) => (json as List).map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<void> markRead(String conversationId) {
    return _client.post<void>(ApiConstants.conversationRead(conversationId));
  }
}

@Riverpod(keepAlive: true)
ChatRemoteDataSource chatRemoteDataSource(ChatRemoteDataSourceRef ref) =>
    ChatRemoteDataSource(ref.watch(apiClientProvider));
