import 'package:econoris_app/data/repositories/users/user_repository.dart';
import 'package:econoris_app/domain/models/users/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UseCase provider pour l'écran de profil.
final profileScreenUseCaseProvider = Provider<ProfileScreenUsecase>((ref) {
  return ProfileScreenUsecase(userRepository: ref.read(userRepositoryProvider));
});

/// UseCase pour l'écran de profil.
class ProfileScreenUsecase {
  ProfileScreenUsecase({required this.userRepository});

  final UserRepository userRepository;

  /// Récupère l'utilisateur actuel.
  Future<User> getCurrentUser() {
    return userRepository.getCurrentUser();
  }

  /// Déconnecte l'utilisateur de tous les appareils.
  Future<void> logout() {
    return userRepository.logout();
  }

  /// Déconnecte l'utilisateur de tous les appareils.
  Future<void> logoutAll() {
    return userRepository.logoutAll();
  }
}
