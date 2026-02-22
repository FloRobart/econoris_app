import 'package:econoris_app/providers/data/services/auth_manager_provider.dart';
import 'package:econoris_app/routing/routes.dart';
import 'package:econoris_app/ui/auth/widgets/code_entry_screen.dart';
import 'package:econoris_app/ui/auth/widgets/login_screen.dart';
import 'package:econoris_app/ui/home/widgets/home_screen.dart';
import 'package:econoris_app/ui/operations/widgets/operation_screen.dart';
import 'package:econoris_app/ui/profile/widgets/profile_screen.dart';
import 'package:econoris_app/ui/subscriptions/widgets/subscriptions_screen.dart';
import 'package:econoris_app/utils/stream_listenable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


final routerProvider = Provider<GoRouter>((ref) {
  final authManager = ref.watch(authManagerProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) => _redirect(ref, state),
    refreshListenable: StreamListenable(authManager.userChanges()),
    routes: [
        /* Home */
        GoRoute(path: AppRoutes.home, name: AppRoutes.home, builder: (context, state) => const HomeScreen()),

        /* Auth */
        GoRoute(path: AppRoutes.login, name: AppRoutes.login, builder: (context, state) => const LoginScreen()),
        GoRoute(path: AppRoutes.codeEntry, name: AppRoutes.codeEntry, builder: (context, state) => const CodeEntryScreen()),

        /* Profile */
        GoRoute(path: AppRoutes.profile, name: AppRoutes.profile, builder: (context, state) => const ProfileScreen()),

        /* Operations */
        GoRoute(path: AppRoutes.operations, name: AppRoutes.operations, builder: (context, state) => const OperationScreen()),

        /* Subscriptions */
        GoRoute(path: AppRoutes.subscriptions, name: AppRoutes.subscriptions, builder: (context, state) => const SubscriptionsScreen()),
    ],
  );
});

// From https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/redirection.dart
Future<String?> _redirect(Ref ref, GoRouterState state) async {
  final loggedIn = ref.read(authManagerProvider).currentUser != null;
  final loggingIn = state.matchedLocation == AppRoutes.login;

  // if the user isn't logged and not on login page, redirect to login page
  if (!loggedIn && !loggingIn) {
    return AppRoutes.login;
  }

  // if the user is logged in but still on the login page, redirect to home page
  if (loggedIn && loggingIn) {
    return AppRoutes.home;
  }

  // no need to redirect at all
  return null;
}
