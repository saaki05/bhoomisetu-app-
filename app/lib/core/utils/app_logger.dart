import 'package:logger/logger.dart';

/// Single shared [Logger] instance. Feature code should call `AppLogger.i`
/// instead of `print`/`debugPrint` so log level, filtering, and future
/// remote-log shipping stay centralized in one place.
abstract final class AppLogger {
  static final Logger instance = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 6,
      lineLength: 100,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void d(String message) => instance.d(message);
  static void i(String message) => instance.i(message);
  static void w(String message) => instance.w(message);
  static void e(String message, [Object? error, StackTrace? stackTrace]) =>
      instance.e(message, error: error, stackTrace: stackTrace);
}
