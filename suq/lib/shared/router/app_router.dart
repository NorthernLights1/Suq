import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import 'app_routes.dart';

/// A [ChangeNotifier] that refreshes the router whenever auth state changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier() {
    Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }
}

final _authRefreshNotifier = _AuthRefreshNotifier();

GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: _authRefreshNotifier,
    redirect: (context, state) async {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final loc = state.matchedLocation;

      final isAuthRoute = loc == AppRoutes.login || loc == AppRoutes.signup;

      if (!isLoggedIn) {
        return isAuthRoute ? null : AppRoutes.login;
      }

      // Logged in — check if onboarding is needed
      if (loc == AppRoutes.onboarding) return null;

      if (isAuthRoute || loc == AppRoutes.login) {
        // Check if user has a shop
        final shopData = await Supabase.instance.client
            .from('shops')
            .select('id')
            .eq('owner_id', session.user.id)
            .maybeSingle();

        if (shopData == null) return AppRoutes.onboarding;
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      // Feature routes — placeholder shells until Phase 3
      GoRoute(path: AppRoutes.sales,     builder: (context, state) => const _ShellPage(title: 'Sales')),
      GoRoute(path: AppRoutes.newSale,   builder: (context, state) => const _ShellPage(title: 'New Sale')),
      GoRoute(path: AppRoutes.inventory, builder: (context, state) => const _ShellPage(title: 'Inventory')),
      GoRoute(path: AppRoutes.customers, builder: (context, state) => const _ShellPage(title: 'Customers')),
      GoRoute(path: AppRoutes.expenses,  builder: (context, state) => const _ShellPage(title: 'Expenses')),
      GoRoute(path: AppRoutes.reports,   builder: (context, state) => const _ShellPage(title: 'Reports')),
      GoRoute(path: AppRoutes.settings,  builder: (context, state) => const _ShellPage(title: 'Settings')),
      GoRoute(path: AppRoutes.staff,     builder: (context, state) => const _ShellPage(title: 'Staff')),
    ],
  );
}

/// Minimal scaffold shown for routes not yet built.
class _ShellPage extends StatelessWidget {
  const _ShellPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('$title — coming soon', style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
