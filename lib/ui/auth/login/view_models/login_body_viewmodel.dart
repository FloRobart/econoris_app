import 'package:econoris_app/domain/use_cases/auth/login/login_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [LoginBodyViewModel].
final loginBodyViewModelProvider = Provider<LoginBodyViewModel>((ref) {
  return LoginBodyViewModel(
    authScreenUseCase: ref.read(loginUseCaseProvider),
  );
});

/// Fournit l'email par défaut pour l'écran d'authentification.
final authInitialEmailProvider = FutureProvider<String?>((ref) async {
  final viewModel = ref.read(loginBodyViewModelProvider);
  return viewModel.getEmail;
});


/// ViewModel pour la logique de l'écran de connexion.
class LoginBodyViewModel {
  LoginBodyViewModel({required this.authScreenUseCase});

  final LoginUseCase authScreenUseCase;

  Future<String?> get getEmail => authScreenUseCase.getEmail;

  Future<bool> loginRequest(String email) async {
    try {
      await authScreenUseCase.loginRequest(email);
      return true;
    } catch (e) {
      return false;
    }
  }
}
