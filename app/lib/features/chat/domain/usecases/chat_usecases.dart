import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/failure.dart';
import '../../data/repositories_impl/chat_repository_impl.dart';
import '../entities/chat_entities.dart';
import '../repositories/chat_repository.dart';

part 'chat_usecases.g.dart';

class ListConversationsUseCase {
  ListConversationsUseCase(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, List<ChatConversation>>> call() => _repository.listConversations();
}

class StartConversationUseCase {
  StartConversationUseCase(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, ChatConversation>> call({required String otherUserId, String? listingId}) =>
      _repository.startConversation(otherUserId: otherUserId, listingId: listingId);
}

class ListMessagesUseCase {
  ListMessagesUseCase(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, PaginatedMessages>> call(String conversationId, {int page = 1}) =>
      _repository.listMessages(conversationId, page: page);
}

class SendChatMessageUseCase {
  SendChatMessageUseCase(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, ChatMessage>> call({
    required String conversationId,
    required MessageType type,
    required String content,
  }) =>
      _repository.sendMessage(conversationId: conversationId, type: type, content: content);
}

class MarkConversationReadUseCase {
  MarkConversationReadUseCase(this._repository);

  final ChatRepository _repository;

  Future<Either<Failure, Unit>> call(String conversationId) => _repository.markRead(conversationId);
}

@riverpod
ListConversationsUseCase listConversationsUseCase(ListConversationsUseCaseRef ref) =>
    ListConversationsUseCase(ref.watch(chatRepositoryProvider));

@riverpod
StartConversationUseCase startConversationUseCase(StartConversationUseCaseRef ref) =>
    StartConversationUseCase(ref.watch(chatRepositoryProvider));

@riverpod
ListMessagesUseCase listMessagesUseCase(ListMessagesUseCaseRef ref) =>
    ListMessagesUseCase(ref.watch(chatRepositoryProvider));

@riverpod
SendChatMessageUseCase sendChatMessageUseCase(SendChatMessageUseCaseRef ref) =>
    SendChatMessageUseCase(ref.watch(chatRepositoryProvider));

@riverpod
MarkConversationReadUseCase markConversationReadUseCase(MarkConversationReadUseCaseRef ref) =>
    MarkConversationReadUseCase(ref.watch(chatRepositoryProvider));
