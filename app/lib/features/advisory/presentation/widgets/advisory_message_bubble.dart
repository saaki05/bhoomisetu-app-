import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/advisory_message.dart';

class AdvisoryMessageBubble extends StatelessWidget {
  const AdvisoryMessageBubble({super.key, required this.message});

  final AdvisoryMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AdvisoryRole.user;
    final colors = context.colors;

    Color bubbleColor;
    Color textColor;
    if (message.isError) {
      bubbleColor = colors.errorContainer;
      textColor = colors.onErrorContainer;
    } else if (isUser) {
      bubbleColor = colors.primary;
      textColor = colors.onPrimary;
    } else {
      bubbleColor = colors.surfaceContainerHigh;
      textColor = colors.onSurface;
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: colors.primaryContainer,
              child: Icon(Icons.eco_rounded, size: 16, color: colors.onPrimaryContainer),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(maxWidth: context.screenSize.width * 0.72),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
            ),
            child: Text(message.content, style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }
}
