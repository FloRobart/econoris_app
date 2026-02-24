import 'package:econoris_app/providers/data/repositories/auth/auth_repository_provider.dart';
import 'package:econoris_app/data/services/auth/global_auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ce fichier contient le [GlobalAuthNotifier] qui gère l'état d'authentification global de l'application.
class GlobalAuthNotifier extends Notifier<AuthStatus> {
  @override
  AuthStatus build() {
    _init();
    return AuthStatus.unknown;
  }

  Future<void> _init() async {
    final isLogged =
        await ref.read(authRepositoryProvider).isLoggedIn();

    state = isLogged
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = AuthStatus.unauthenticated;
  }

  void setAuthenticated() {
    state = AuthStatus.authenticated;
  }
}
