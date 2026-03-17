import 'package:econoris_app/domain/models/users/user.dart';
import 'package:econoris_app/domain/use_cases/users/profile_screen_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider pour le ViewModel de l'écran de profil.
final profileScreenViewModelProvider = Provider<ProfileScreenViewmodel>((ref) {
  final useCase = ref.read(profileScreenUseCaseProvider);
  return ProfileScreenViewmodel(useCase);
});

/// Provider asynchrone de l'utilisateur courant.
final profileCurrentUserProvider = FutureProvider.autoDispose<User>((ref) async {
  return ref.read(profileScreenViewModelProvider).getCurrentUser;
});

/// ViewModel pour l'écran de profil.
class ProfileScreenViewmodel {
  ProfileScreenViewmodel(this.useCase);

  final ProfileScreenUsecase useCase;
  late User _user;


  /* Getters */
  Future<User> get getCurrentUser => useCase.getCurrentUser();
  String get getUserEmail => _user.email;
  String get getUserPseudo => _user.pseudo;
  bool get isUserConnected => _user.isConnected;
  bool get isUserEmailVerified => _user.isVerifiedEmail;
  DateTime get getUserCreatedAt => _user.createdAt;

  /* Setters */
  set setUser(User user) => _user = user;

  /* View functions */
  void updatePseudo(String newPseudo) {
    useCase.updatePseudo(newPseudo);
  }

  /// Déconnecte l'utilisateur de l'appareil actuel.
  void logout() {
    useCase.logout();
  }

  /// Déconnecte l'utilisateur de tous les appareils.
  void logoutAll() {
    useCase.logoutAll();
  }
}
