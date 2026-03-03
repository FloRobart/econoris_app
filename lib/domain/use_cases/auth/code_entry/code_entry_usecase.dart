import 'package:econoris_app/data/repositories/auth/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [CodeEntryUseCase].
final codeEntryUseCaseProvider = Provider<CodeEntryUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return CodeEntryUseCase(authRepository: authRepository);
});

/// Cas d'utilisation pour la requête de connexion de l'utilisateur.
class CodeEntryUseCase {
  CodeEntryUseCase({required this.authRepository});

  final AuthRepository authRepository;

  Future<bool> verifyCode(String code) async {
    try {
      return await authRepository.confirmLoginCode(code);
    } catch (e) {
      throw Exception('Failed to verify code');
    }
  }
}
