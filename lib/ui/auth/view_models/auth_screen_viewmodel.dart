import 'package:econoris_app/domain/use_cases/auth/auth_screen_usecase.dart';

class AuthScreenViewModel {
  AuthScreenViewModel({required this.authScreenUseCase});

  final AuthScreenUseCase authScreenUseCase;

  Future<String?> get getEmail => authScreenUseCase.getEmail;

  Future<bool> loginRequest(String email) async {
    try {
      await authScreenUseCase.loginRequest(email);
      return true;
    } catch (e) {
      print('Login request failed: $e');
      return false;
    }
  }

  void register(String email, String pseudo) {
    authScreenUseCase.register(email, pseudo);
  }
}
