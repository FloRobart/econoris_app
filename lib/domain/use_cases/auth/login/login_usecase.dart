import 'package:econoris_app/data/repositories/auth/auth_repository.dart';
import 'package:econoris_app/providers/data/repositories/auth/auth_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [LoginUseCase].
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LoginUseCase(authRepository: authRepository);
});

/// Cas d'utilisation pour la requête de connexion de l'utilisateur.
class LoginUseCase {
  LoginUseCase({required this.authRepository});

  final AuthRepository authRepository;

  Future<String?> get getEmail => authRepository.getEmail();

  Future<void> loginRequest(String email) async {
    await authRepository.requestLoginCode(email);
  }

  Future<void> verifyCode(String code) async {
    await authRepository.confirmLoginCode(code);
  }

  void register(String email, String pseudo) {
    // Implement registration logic here
  }
}
