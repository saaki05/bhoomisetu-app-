import 'dart:async';

/// Delays invoking [run] until [delay] has passed without another call —
/// used for search-as-you-type fields so every keystroke doesn't fire a
/// network request.
class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 400)});

  final Duration delay;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() => _timer?.cancel();
}
