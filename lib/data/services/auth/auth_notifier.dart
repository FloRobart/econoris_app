import 'dart:async';
import 'package:econoris_app/data/services/auth/global_auth_notifier.dart';
import 'package:econoris_app/domain/use_cases/auth/login/login_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Pas de logique ici
  }

  Future<void> login(String email) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      ref.read(loginUseCaseProvider).loginRequest(email);

      // 🔥 ICI on met authenticated
      ref.read(globalAuthProvider.notifier).setAuthenticated();
    });
  }
}
