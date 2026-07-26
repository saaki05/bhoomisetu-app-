import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Base URLs and endpoint paths for the BhoomiSetu backend API.
/// Base values come from `.env` (see `.env.example`); endpoint paths are
/// fixed contracts shared with the Node.js backend's route definitions.
abstract final class ApiConstants {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:4000/api/v1';
  static String get socketUrl => dotenv.env['SOCKET_URL'] ?? 'http://10.0.2.2:4000';

  // Generous enough to survive a free-tier host cold start: Render spins
  // idle services down after ~15 minutes and the next request waits ~30-50s
  // while the container boots. Shorter timeouts surface that as a bogus
  // "no internet connection" error on the first launch of the day.
  static const Duration connectTimeout = Duration(seconds: 70);
  static const Duration receiveTimeout = Duration(seconds: 70);
  static const Duration sendTimeout = Duration(seconds: 70);

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleSignIn = '/auth/google';
  static const String requestOtp = '/auth/otp/request';
  static const String verifyOtp = '/auth/otp/verify';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';
  static const String selectRole = '/auth/role';

  // Home
  static const String homeSummary = '/home/summary';

  // Marketplace
  static const String cropListings = '/marketplace/listings';
  static String cropListing(String id) => '/marketplace/listings/$id';
  static const String categories = '/marketplace/categories';
  static const String bookmarks = '/marketplace/bookmarks';

  // Orders
  static const String orders = '/orders';
  static String order(String id) => '/orders/$id';
  static String orderStatus(String id) => '/orders/$id/status';
  static String orderReview(String id) => '/orders/$id/review';

  // Chat
  static const String conversations = '/chat/conversations';
  static String conversationMessages(String id) => '/chat/conversations/$id/messages';
  static String conversationRead(String id) => '/chat/conversations/$id/read';

  // Weather
  static const String weatherCurrent = '/weather/current';
  static const String weatherForecast = '/weather/forecast';

  // Government schemes
  static const String schemes = '/schemes';
  static String scheme(String id) => '/schemes/$id';

  // Profile
  static const String profile = '/profile';
  static const String farms = '/profile/farms';
  static const String dashboard = '/profile/dashboard';
}
