import 'package:dartz/dartz.dart';

import '../../../../core/exceptions/failure.dart';
import '../entities/chat_entities.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatConversation>>> listConversations();

  Future<Either<Failure, ChatConversation>> startConversation({required String otherUserId, String? listingId});

  Future<Either<Failure, PaginatedMessages>> listMessages(String conversationId, {int page = 1});

  Future<Either<Failure, ChatMessage>> sendMessage({
    required String conversationId,
    required MessageType type,
    required String content,
  });

  Future<Either<Failure, Unit>> markRead(String conversationId);

  void sendTyping({required String conversationId, required bool isTyping});

  Stream<ChatMessage> get onMessage;
  Stream<TypingEvent> get onTyping;
  Stream<ReadEvent> get onRead;
  Stream<PresenceEvent> get onPresenceUpdate;
}
