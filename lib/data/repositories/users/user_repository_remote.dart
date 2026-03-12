import 'package:econoris_app/data/models/users/user_dto.dart';
import 'package:econoris_app/data/services/api/users/user_api_client.dart';
import 'package:econoris_app/data/services/auth/auth_manager.dart';

class UserRepositoryRemote {
  UserRepositoryRemote({required this.userApiClient, required this.authManager});

  final UserApiClient userApiClient;
  final AuthManager authManager;

  /// Récupère les données de l'utilisateur actuel depuis l'API.
  Future<UserDto> getCurrentUser() async {
    final userData = await userApiClient.getCurrentUser();
    return UserDto.fromJson(userData);
  }

  /// Met à jour le pseudo de l'utilisateur via l'API.
  Future<void> updatePseudo(String newPseudo) async {
    final String email = authManager.getEmail ?? '';
    final jwt = await userApiClient.updatePseudo(newPseudo, email);
    await authManager.setAuthenticated(jwt);
  }

  /// Déconnecte l'utilisateur de tous les appareils via l'API.
  Future<void> logoutAll() async {
    return await userApiClient.logoutAll();
  }
}
