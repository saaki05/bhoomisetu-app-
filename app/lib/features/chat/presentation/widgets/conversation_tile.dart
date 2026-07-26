import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../domain/entities/chat_entities.dart';
import '../providers/presence_provider.dart';

class ConversationTile extends ConsumerWidget {
  const ConversationTile({super.key, required this.conversation, required this.onTap});

  final ChatConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final other = conversation.otherParticipant;
    final isOnline = other != null && (ref.watch(isUserOnlineProvider(other.id)).valueOrNull ?? false);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: context.colors.secondaryContainer,
            backgroundImage: other?.avatarUrl != null ? NetworkImage(other!.avatarUrl!) : null,
            child: other?.avatarUrl == null
                ? Text((other?.fullName ?? '?').initials, style: TextStyle(color: context.colors.onSecondaryContainer))
                : null,
          ),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.surface, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        other?.fullName ?? 'Unknown user',
        style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        conversation.lastMessagePreview ?? 'Say hello 👋',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (conversation.lastMessageAt != null)
            Text(
              DateTime.parse(conversation.lastMessageAt!).timeAgo,
              style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
            ),
          if (conversation.unreadCount > 0) ...[
            const SizedBox(height: 4),
            CircleAvatar(
              radius: 10,
              backgroundColor: context.colors.primary,
              child: Text(
                '${conversation.unreadCount}',
                style: TextStyle(color: context.colors.onPrimary, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
