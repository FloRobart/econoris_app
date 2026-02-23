import 'package:econoris_app/data/repositories/auth/auth_repository.dart';

class AuthScreenUseCase {
  AuthScreenUseCase({required this.authRepository});

  final AuthRepository authRepository;

  Future<String?> get getEmail => authRepository.getEmail();

  Future<void> loginRequest(String email) async {
    await authRepository.requestLoginCode(email);
  }

  void register(String email, String pseudo) {
    // Implement registration logic here
  }
}
