import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/authentication/presentation/providers/auth_controller.dart';
import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/otp_verification_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/chat/presentation/screens/conversations_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/marketplace/presentation/screens/marketplace_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../shared/screens/app_shell.dart';
import '../../shared/screens/splash_screen.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

const _authRoutes = {
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.otpVerification,
  AppRoutes.forgotPassword,
};

/// Notifies GoRouter to re-run its `redirect` callback whenever auth state
/// changes. Deliberately a plain [ChangeNotifier] passed as
/// `refreshListenable` rather than having the `appRouter` provider itself
/// `watch` [authControllerProvider]: watching it there would rebuild the
/// entire [GoRouter] object on every auth change, tearing down and
/// recreating the whole navigator element tree mid-transition — which
/// corrupts in-flight widget state (observed as a `NotInitializedError`
/// from screens reading providers in `initState`). Listening instead lets
/// the same long-lived GoRouter simply re-evaluate `redirect`.
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(AppRouterRef ref) {
    ref.listen(authControllerProvider, (previous, next) => notifyListeners());
  }
}

/// Top-level navigation graph with a redirect gate driven by
/// [authControllerProvider]: unauthenticated users are confined to the auth
/// routes, authenticated users are bounced away from them to Home, and the
/// splash screen is shown only while the initial session restore is
/// in flight. Home/Marketplace (and Orders/Chat/Profile as they land) live
/// inside a [StatefulShellRoute] so the bottom nav bar persists and each
/// tab keeps its own navigation stack.
@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final refreshListenable = _AuthRefreshListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isBootstrapping = authState.isLoading && !authState.hasValue;
      final isLoggedIn = authState.valueOrNull != null;
      final path = state.matchedLocation;

      if (isBootstrapping) {
        return path == AppRoutes.splash ? null : AppRoutes.splash;
      }
      if (!isLoggedIn) {
        return _authRoutes.contains(path) ? null : AppRoutes.login;
      }
      if (_authRoutes.contains(path) || path == AppRoutes.splash) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.marketplace, builder: (context, state) => const MarketplaceScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.orders, builder: (context, state) => const OrdersScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.chat, builder: (context, state) => const ConversationsScreen()),
          ]),
        ],
      ),
    ],
  );
}
