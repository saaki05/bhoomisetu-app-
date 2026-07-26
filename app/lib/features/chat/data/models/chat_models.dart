import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/chat_entities.dart';

part 'chat_models.g.dart';

@JsonSerializable(createToJson: false)
class ChatParticipantModel {
  ChatParticipantModel({required this.id, required this.fullName, this.avatarUrl});

  factory ChatParticipantModel.fromJson(Map<String, dynamic> json) => _$ChatParticipantModelFromJson(json);

  final String id;
  final String fullName;
  final String? avatarUrl;

  ChatParticipant toEntity() => ChatParticipant(id: id, fullName: fullName, avatarUrl: avatarUrl);
}

@JsonSerializable(createToJson: false)
class ChatMessageModel {
  ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.content,
    this.readAt,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => _$ChatMessageModelFromJson(json);

  final String id;
  final String conversationId;
  final String senderId;
  final String type;
  final String content;
  final String? readAt;
  final String createdAt;

  ChatMessage toEntity() => ChatMessage(
        id: id,
        conversationId: conversationId,
        senderId: senderId,
        type: MessageType.fromApiValue(type),
        content: content,
        readAt: readAt,
        createdAt: createdAt,
      );
}

@JsonSerializable(createToJson: false)
class ChatConversationModel {
  ChatConversationModel({
    required this.id,
    this.otherParticipant,
    this.listingId,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadCount = 0,
    required this.createdAt,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) => _$ChatConversationModelFromJson(json);

  final String id;
  final ChatParticipantModel? otherParticipant;
  final String? listingId;
  final String? lastMessagePreview;
  final String? lastMessageAt;
  final int unreadCount;
  final String createdAt;

  ChatConversation toEntity() => ChatConversation(
        id: id,
        otherParticipant: otherParticipant?.toEntity(),
        listingId: listingId,
        lastMessagePreview: lastMessagePreview,
        lastMessageAt: lastMessageAt,
        unreadCount: unreadCount,
        createdAt: createdAt,
      );
}
