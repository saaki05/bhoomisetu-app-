import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/exceptions/failure.dart';
import '../../../../core/network/socket_client.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_models.dart';

part 'chat_repository_impl.g.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remote, this._socket);

  final ChatRemoteDataSource _remote;
  final SocketClient _socket;

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on AppException catch (e) {
      return Left(failureFromException(e));
    }
  }

  @override
  Future<Either<Failure, List<ChatConversation>>> listConversations() =>
      _guard(() async => (await _remote.listConversations()).map((m) => m.toEntity()).toList());

  @override
  Future<Either<Failure, ChatConversation>> startConversation({required String otherUserId, String? listingId}) =>
      _guard(() async => (await _remote.startConversation(otherUserId: otherUserId, listingId: listingId)).toEntity());

  @override
  Future<Either<Failure, PaginatedMessages>> listMessages(String conversationId, {int page = 1}) {
    return _guard(() async {
      final (items, meta) = await _remote.listMessages(conversationId, page: page);
      return PaginatedMessages(
        items: items.map((m) => m.toEntity()).toList(),
        page: (meta?['page'] as int?) ?? page,
        totalPages: (meta?['totalPages'] as int?) ?? 1,
      );
    });
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String conversationId,
    required MessageType type,
    required String content,
  }) async {
    final response = await _socket.sendMessage(conversationId: conversationId, type: type.apiValue, content: content);
    if (response['success'] != true) {
      return Left(Failure.unknown(response['error'] as String? ?? 'Failed to send message'));
    }
    final model = ChatMessageModel.fromJson(Map<String, dynamic>.from(response['message'] as Map));
    return Right(model.toEntity());
  }

  @override
  Future<Either<Failure, Unit>> markRead(String conversationId) async {
    await _socket.markRead(conversationId);
    return const Right(unit);
  }

  @override
  void sendTyping({required String conversationId, required bool isTyping}) =>
      _socket.sendTyping(conversationId: conversationId, isTyping: isTyping);

  @override
  Stream<ChatMessage> get onMessage =>
      _socket.onMessage.map((json) => ChatMessageModel.fromJson(json).toEntity());

  @override
  Stream<TypingEvent> get onTyping => _socket.onTyping.map((json) => TypingEvent(
        conversationId: json['conversationId'] as String,
        userId: json['userId'] as String,
        isTyping: json['isTyping'] as bool,
      ));

  @override
  Stream<ReadEvent> get onRead => _socket.onRead.map(
        (json) => ReadEvent(conversationId: json['conversationId'] as String, readBy: json['readBy'] as String),
      );

  @override
  Stream<PresenceEvent> get onPresenceUpdate => _socket.onPresenceUpdate.map(
        (json) => PresenceEvent(userId: json['userId'] as String, isOnline: json['isOnline'] as bool),
      );
}

@Riverpod(keepAlive: true)
ChatRepository chatRepository(ChatRepositoryRef ref) =>
    ChatRepositoryImpl(ref.watch(chatRemoteDataSourceProvider), ref.watch(socketClientProvider));
