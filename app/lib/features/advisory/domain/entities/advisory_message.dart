import 'package:freezed_annotation/freezed_annotation.dart';

part 'advisory_message.freezed.dart';

enum AdvisoryRole { user, assistant }

@freezed
abstract class AdvisoryMessage with _$AdvisoryMessage {
  const factory AdvisoryMessage({
    required AdvisoryRole role,
    required String content,
    @Default(false) bool isError,
  }) = _AdvisoryMessage;
}
