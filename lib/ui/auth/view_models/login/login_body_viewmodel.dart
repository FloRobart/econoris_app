import 'package:econoris_app/domain/use_cases/auth/login/login_usecase.dart';

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

  void register(String email, String pseudo) {
    authScreenUseCase.register(email, pseudo);
  }
}
