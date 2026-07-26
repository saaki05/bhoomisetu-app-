import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/states/async_value_widget.dart';
import '../../../../core/widgets/states/shimmer_box.dart';
import '../../domain/entities/chat_entities.dart';
import '../providers/conversations_list_controller.dart';
import '../widgets/conversation_tile.dart';
import 'chat_thread_screen.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: AsyncValueWidget<List<ChatConversation>>(
        value: conversationsAsync,
        loading: () => const ShimmerListPlaceholder(),
        onRetry: () => ref.read(conversationsListControllerProvider.notifier).refresh(),
        isEmpty: (items) => items.isEmpty,
        emptyMessage: 'No conversations yet.\nStart one from a listing or an order.',
        emptyIcon: Icons.chat_bubble_outline_rounded,
        data: (conversations) => RefreshIndicator(
          onRefresh: () => ref.read(conversationsListControllerProvider.notifier).refresh(),
          child: ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return ConversationTile(
                conversation: conversation,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ChatThreadScreen(conversation: conversation)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
