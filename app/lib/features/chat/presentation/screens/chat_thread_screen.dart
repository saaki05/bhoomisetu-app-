import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/widgets/states/async_value_widget.dart';
import '../../domain/entities/chat_entities.dart';
import '../providers/chat_thread_controller.dart';
import '../providers/conversations_list_controller.dart';
import '../providers/presence_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({super.key, required this.conversation});

  final ChatConversation conversation;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _typingStopTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(chatThreadControllerProvider(widget.conversation.id).notifier).loadMore();
    }
  }

  void _onTextChanged(String value) {
    final notifier = ref.read(chatThreadControllerProvider(widget.conversation.id).notifier);
    if (value.isNotEmpty && !_isTyping) {
      _isTyping = true;
      notifier.setTyping(true);
    }
    _typingStopTimer?.cancel();
    _typingStopTimer = Timer(const Duration(seconds: 2), () {
      _isTyping = false;
      notifier.setTyping(false);
    });
  }

  Future<void> _send() async {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;
    _messageController.clear();
    _typingStopTimer?.cancel();
    _isTyping = false;

    final error = await ref.read(chatThreadControllerProvider(widget.conversation.id).notifier).sendText(text);
    if (error != null && mounted) {
      context.showSnackBar(error, isError: true);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingStopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final threadAsync = ref.watch(chatThreadControllerProvider(widget.conversation.id));
    final currentUserId = ref.watch(currentUserIdProvider);
    final other = widget.conversation.otherParticipant;
    final isOnline = other != null && (ref.watch(isUserOnlineProvider(other.id)).valueOrNull ?? false);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: context.colors.secondaryContainer,
              backgroundImage: other?.avatarUrl != null ? NetworkImage(other!.avatarUrl!) : null,
              child: other?.avatarUrl == null
                  ? Text((other?.fullName ?? '?').initials,
                      style: TextStyle(fontSize: 12, color: context.colors.onSecondaryContainer))
                  : null,
            ),
            const SizedBox(width: AppConstants.spaceSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(other?.fullName ?? 'Unknown user', style: context.textTheme.titleSmall),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: isOnline ? Colors.green : context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: AsyncValueWidget<ChatThreadState>(
              value: threadAsync,
              onRetry: () => ref.invalidate(chatThreadControllerProvider(widget.conversation.id)),
              isEmpty: (state) => state.messages.isEmpty,
              emptyMessage: 'No messages yet. Say hello!',
              emptyIcon: Icons.chat_bubble_outline_rounded,
              data: (state) => ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.all(AppConstants.spaceLg),
                itemCount: state.messages.length + (state.otherUserTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (state.otherUserTyping && index == 0) {
                    return const TypingIndicator();
                  }
                  final messageIndex = state.otherUserTyping ? index - 1 : index;
                  final message = state.messages[messageIndex];
                  return MessageBubble(message: message, isMine: message.senderId == currentUserId);
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceSm),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      onChanged: _onTextChanged,
                      decoration: const InputDecoration(hintText: 'Type a message…'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  IconButton.filled(icon: const Icon(Icons.send_rounded), onPressed: _send),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
