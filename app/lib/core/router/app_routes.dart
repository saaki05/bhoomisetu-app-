/// Centralized route path constants. Every `GoRoute.path` and every
/// `context.go(...)`/`context.push(...)` call should reference a constant
/// from here instead of a string literal, so a path rename is a one-line
/// change instead of a repo-wide find/replace.
abstract final class AppRoutes {
  static const String splash = '/splash';

  // Authentication
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String selectRole = '/select-role';

  // Shell
  static const String home = '/home';
  static const String marketplace = '/marketplace';
  static const String orders = '/orders';
  static const String chat = '/chat';
  static const String profile = '/profile';
}
