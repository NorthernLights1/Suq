import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

part 'app_routes.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  redirect: _globalRedirect,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (_, __) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (_, __) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (_, __) => const DashboardScreen(),
    ),
  ],
);

String? _globalRedirect(BuildContext context, GoRouterState state) {
  final session = Supabase.instance.client.auth.currentSession;
  final isLoggedIn = session != null;
  final isOnAuthRoute = state.matchedLocation == AppRoutes.login ||
      state.matchedLocation == AppRoutes.signup;

  if (!isLoggedIn && !isOnAuthRoute) return AppRoutes.login;
  if (isLoggedIn && isOnAuthRoute) return AppRoutes.dashboard;
  return null;
}
