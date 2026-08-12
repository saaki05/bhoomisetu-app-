import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../providers/advisory_chat_controller.dart';
import '../widgets/advisory_message_bubble.dart';

const List<String> _suggestedPrompts = [
  'Best fertilizer for wheat this season?',
  'How do I control aphids on my crop?',
  'When should I harvest my tomatoes?',
  'Suggest a crop for sandy, low-water soil',
];

class AdvisoryChatScreen extends ConsumerStatefulWidget {
  const AdvisoryChatScreen({super.key});

  @override
  ConsumerState<AdvisoryChatScreen> createState() => _AdvisoryChatScreenState();
}

class _AdvisoryChatScreenState extends ConsumerState<AdvisoryChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send([String? text]) async {
    final value = text ?? _controller.text;
    if (value.trim().isEmpty) return;
    _controller.clear();
    await ref.read(advisoryChatControllerProvider.notifier).send(value);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(advisoryChatControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Farming Advisor'),
        actions: [
          if (state.messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Clear conversation',
              onPressed: () => ref.read(advisoryChatControllerProvider.notifier).clear(),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.messages.isEmpty
                ? _EmptyState(onPromptTap: _send)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppConstants.spaceLg),
                    itemCount: state.messages.length + (state.isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.messages.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      return AdvisoryMessageBubble(message: state.messages[index]);
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceSm),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(hintText: 'Ask about crops, pests, fertilizer…'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  IconButton.filled(
                    icon: const Icon(Icons.send_rounded),
                    onPressed: state.isSending ? null : () => _send(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onPromptTap});

  final void Function(String) onPromptTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco_rounded, size: 56, color: context.colors.primary),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'Ask your AI farming advisor',
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            'Crop selection, pests, fertilizer, irrigation — ask anything.',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _suggestedPrompts
                .map((prompt) => ActionChip(label: Text(prompt), onPressed: () => onPromptTap(prompt)))
                .toList(),
          ),
        ],
      ),
    );
  }
}
