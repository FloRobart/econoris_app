import 'package:econoris_app/providers/routing/global_auth_provider.dart';
import 'package:econoris_app/routing/global_auth_state.dart';
import 'package:econoris_app/routing/routes.dart';
import 'package:econoris_app/ui/auth/widgets/code_entry_screen.dart';
import 'package:econoris_app/ui/auth/widgets/auth_screen.dart';
import 'package:econoris_app/ui/home/widgets/home_screen.dart';
import 'package:econoris_app/ui/operations/widgets/operation_screen.dart';
import 'package:econoris_app/ui/profile/widgets/profile_screen.dart';
import 'package:econoris_app/ui/subscriptions/widgets/subscriptions_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(globalAuthProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,

    redirect: (context, state) {
      final isAuth = authStatus == AuthStatus.authenticated;
      final isUnknown = authStatus == AuthStatus.unknown;

      final isAuthRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.codeEntry;

      // Statut inconnu → on attend de savoir si l'utilisateur est connecté ou pas
      if (isUnknown) {
        return null;
      }

      // Non connecté → accès seulement aux routes auth
      if (!isAuth && !isAuthRoute) {
        return AppRoutes.login;
      }

      // Connecté → pas accès login
      if (isAuth && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const AuthScreen()),
      GoRoute(
        path: AppRoutes.codeEntry,
        builder: (_, _) => const CodeEntryScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.operations,
        builder: (_, _) => const OperationScreen(),
      ),
      GoRoute(
        path: AppRoutes.subscriptions,
        builder: (_, _) => const SubscriptionsScreen(),
      ),
    ],
  );
});
