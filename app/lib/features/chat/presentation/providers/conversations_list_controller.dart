import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../authentication/presentation/providers/auth_controller.dart';
import '../../data/repositories_impl/chat_repository_impl.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/usecases/chat_usecases.dart';

part 'conversations_list_controller.g.dart';

@riverpod
class ConversationsListController extends _$ConversationsListController {
  StreamSubscription<ChatMessage>? _messageSub;

  @override
  Future<List<ChatConversation>> build() async {
    ref.onDispose(() => _messageSub?.cancel());
    _messageSub = ref.watch(chatRepositoryProvider).onMessage.listen((_) => refresh());

    final result = await ref.watch(listConversationsUseCaseProvider).call();
    return result.fold((failure) => throw failure, (conversations) => conversations);
  }

  Future<void> refresh() async {
    final result = await ref.read(listConversationsUseCaseProvider).call();
    result.fold((failure) => state = AsyncError(failure, StackTrace.current), (conversations) {
      state = AsyncData(conversations);
    });
  }

  Future<ChatConversation?> startConversation({required String otherUserId, String? listingId}) async {
    final result = await ref.read(startConversationUseCaseProvider).call(otherUserId: otherUserId, listingId: listingId);
    return result.fold((failure) => null, (conversation) {
      refresh();
      return conversation;
    });
  }
}

/// Total unread messages across all conversations — drives a badge on the
/// Chat tab in the bottom nav.
@riverpod
int totalUnreadMessages(TotalUnreadMessagesRef ref) {
  final conversations = ref.watch(conversationsListControllerProvider).valueOrNull ?? [];
  return conversations.fold(0, (sum, c) => sum + c.unreadCount);
}

/// Reference to the current user id, used across chat widgets to decide
/// message alignment (mine vs. theirs).
@riverpod
String? currentUserId(CurrentUserIdRef ref) => ref.watch(authControllerProvider).valueOrNull?.id;
