import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/advisory_message.dart';
import '../../domain/usecases/send_advisory_message_usecase.dart';

part 'advisory_chat_controller.freezed.dart';
part 'advisory_chat_controller.g.dart';

@freezed
abstract class AdvisoryChatState with _$AdvisoryChatState {
  const factory AdvisoryChatState({
    @Default([]) List<AdvisoryMessage> messages,
    @Default(false) bool isSending,
  }) = _AdvisoryChatState;
}

@riverpod
class AdvisoryChatController extends _$AdvisoryChatController {
  @override
  AdvisoryChatState build() => const AdvisoryChatState();

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;

    final history = state.messages;
    state = state.copyWith(
      messages: [...state.messages, AdvisoryMessage(role: AdvisoryRole.user, content: trimmed)],
      isSending: true,
    );

    final result = await ref.read(sendAdvisoryMessageUseCaseProvider).call(message: trimmed, history: history);

    result.fold(
      (failure) => state = state.copyWith(
        messages: [...state.messages, AdvisoryMessage(role: AdvisoryRole.assistant, content: failure.message, isError: true)],
        isSending: false,
      ),
      (reply) => state = state.copyWith(
        messages: [...state.messages, AdvisoryMessage(role: AdvisoryRole.assistant, content: reply)],
        isSending: false,
      ),
    );
  }

  void clear() => state = const AdvisoryChatState();
}
