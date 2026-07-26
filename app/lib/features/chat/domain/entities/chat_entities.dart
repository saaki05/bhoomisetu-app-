import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_entities.freezed.dart';

enum MessageType {
  text,
  image,
  document;

  static MessageType fromApiValue(String value) => MessageType.values.firstWhere(
        (t) => t.name == value,
        orElse: () => MessageType.text,
      );

  String get apiValue => name;
}

@freezed
abstract class ChatParticipant with _$ChatParticipant {
  const factory ChatParticipant({required String id, required String fullName, String? avatarUrl}) =
      _ChatParticipant;
}

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String conversationId,
    required String senderId,
    required MessageType type,
    required String content,
    String? readAt,
    required String createdAt,
  }) = _ChatMessage;
}

@freezed
abstract class TypingEvent with _$TypingEvent {
  const factory TypingEvent({required String conversationId, required String userId, required bool isTyping}) =
      _TypingEvent;
}

@freezed
abstract class ReadEvent with _$ReadEvent {
  const factory ReadEvent({required String conversationId, required String readBy}) = _ReadEvent;
}

@freezed
abstract class PresenceEvent with _$PresenceEvent {
  const factory PresenceEvent({required String userId, required bool isOnline}) = _PresenceEvent;
}

@freezed
abstract class PaginatedMessages with _$PaginatedMessages {
  const factory PaginatedMessages({
    required List<ChatMessage> items,
    required int page,
    required int totalPages,
  }) = _PaginatedMessages;
}

@freezed
abstract class ChatConversation with _$ChatConversation {
  const factory ChatConversation({
    required String id,
    ChatParticipant? otherParticipant,
    String? listingId,
    String? lastMessagePreview,
    String? lastMessageAt,
    @Default(0) int unreadCount,
    required String createdAt,
  }) = _ChatConversation;
}
