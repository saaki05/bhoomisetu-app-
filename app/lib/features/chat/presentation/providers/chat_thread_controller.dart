import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories_impl/chat_repository_impl.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/usecases/chat_usecases.dart';
import 'conversations_list_controller.dart';

part 'chat_thread_controller.freezed.dart';
part 'chat_thread_controller.g.dart';

@freezed
abstract class ChatThreadState with _$ChatThreadState {
  const factory ChatThreadState({
    /// Newest message first, matching how the backend paginates.
    required List<ChatMessage> messages,
    required int page,
    required int totalPages,
    @Default(false) bool isLoadingMore,
    @Default(false) bool otherUserTyping,
  }) = _ChatThreadState;
}

@riverpod
class ChatThreadController extends _$ChatThreadController {
  StreamSubscription<ChatMessage>? _messageSub;
  StreamSubscription<TypingEvent>? _typingSub;
  StreamSubscription<ReadEvent>? _readSub;
  Timer? _typingResetTimer;

  @override
  Future<ChatThreadState> build(String conversationId) async {
    ref.onDispose(() {
      _messageSub?.cancel();
      _typingSub?.cancel();
      _readSub?.cancel();
      _typingResetTimer?.cancel();
    });

    final repository = ref.watch(chatRepositoryProvider);

    _messageSub = repository.onMessage.where((m) => m.conversationId == conversationId).listen((message) {
      final current = state.valueOrNull;
      if (current == null) return;
      state = AsyncData(current.copyWith(messages: [message, ...current.messages]));
      ref.read(markConversationReadUseCaseProvider).call(conversationId);
    });

    _typingSub = repository.onTyping.where((e) => e.conversationId == conversationId).listen((event) {
      final current = state.valueOrNull;
      if (current == null) return;
      state = AsyncData(current.copyWith(otherUserTyping: event.isTyping));
      _typingResetTimer?.cancel();
      if (event.isTyping) {
        _typingResetTimer = Timer(const Duration(seconds: 5), () {
          final latest = state.valueOrNull;
          if (latest != null) state = AsyncData(latest.copyWith(otherUserTyping: false));
        });
      }
    });

    _readSub = repository.onRead.where((e) => e.conversationId == conversationId).listen((_) {
      final current = state.valueOrNull;
      if (current == null) return;
      final now = DateTime.now().toIso8601String();
      state = AsyncData(current.copyWith(
        messages: [
          for (final m in current.messages) m.readAt == null ? m.copyWith(readAt: now) : m,
        ],
      ));
    });

    final result = await ref.read(listMessagesUseCaseProvider).call(conversationId);
    await ref.read(markConversationReadUseCaseProvider).call(conversationId);

    return result.fold(
      (failure) => throw failure,
      (paginated) => ChatThreadState(messages: paginated.items, page: paginated.page, totalPages: paginated.totalPages),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || current.page >= current.totalPages) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await ref.read(listMessagesUseCaseProvider).call(conversationId, page: current.page + 1);

    state = result.fold(
      (failure) => AsyncData(current.copyWith(isLoadingMore: false)),
      (paginated) => AsyncData(current.copyWith(
        messages: [...current.messages, ...paginated.items],
        page: paginated.page,
        totalPages: paginated.totalPages,
        isLoadingMore: false,
      )),
    );
  }

  Future<String?> sendText(String content) async {
    if (content.trim().isEmpty) return null;
    setTyping(false);
    final result = await ref
        .read(sendChatMessageUseCaseProvider)
        .call(conversationId: conversationId, type: MessageType.text, content: content.trim());

    return result.fold((failure) => failure.message, (message) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(current.copyWith(messages: [message, ...current.messages]));
      }
      ref.invalidate(conversationsListControllerProvider);
      return null;
    });
  }

  void setTyping(bool isTyping) {
    ref.read(chatRepositoryProvider).sendTyping(conversationId: conversationId, isTyping: isTyping);
  }
}
