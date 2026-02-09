
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:econoris_app/config/dependencies.dart';
import 'login_state.dart';

class LoginViewModel extends Notifier<LoginState> {
  @override
  LoginState build() {
    _loadInitialState();
    return const LoginState.loading();
  }

  Future<void> _loadInitialState() async {
    try {
      final repo = await ref.read(authRepositoryProvider.future);
      final email = await repo.getEmail();

      state = LoginState.enterEmail(email: email);
    } catch (_) {
      state = const LoginState.enterEmail();
    }
  }

  void toggleMode() {
    state.maybeMap(
      enterEmail: (s) {
        state = LoginState.enterEmailAndName(email: s.email);
      },
      enterEmailAndName: (s) {
        state = LoginState.enterEmail(email: s.email);
      },
      orElse: () => state,
    );
  }

  Future<void> requestLoginCode(String email) async {
    final requireName = state is LoginEnterEmailAndName;

    state = LoginState.submitting(
      requireName: requireName,
      email: email,
    );

    try {
      final repo = await ref.read(authRepositoryProvider.future);
      await repo.requestLoginCode(email);

      state = LoginState.enterOtp(email: email);
    } catch (e) {
      state = LoginState.error(message: e.toString());
    }
  }
}

final loginViewModelProvider =
    NotifierProvider<LoginViewModel, LoginState>(
  LoginViewModel.new,
);
