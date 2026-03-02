import 'package:econoris_app/data/services/api/auth/auth_api_client.dart';
import 'package:econoris_app/domain/models/users/user.dart';
import 'package:econoris_app/data/repositories/auth/auth_repository_impl.dart';
import 'package:econoris_app/data/repositories/auth/auth_repository_local.dart';
import 'package:econoris_app/data/repositories/auth/auth_repository_remote.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Fournit une instance asynchrone d'[AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = AuthRepositoryRemote(authApiClient: ref.read(authApiClientProvider));
  final local = AuthRepositoryLocal();

  return AuthRepositoryImpl(remote: remote, local: local);
});


/// Repository interface for authentication operations.
abstract class AuthRepository {
  Future<void> requestLoginCode(String email);
  Future<void> confirmLoginCode(String secret);
  Future<String?> getEmail();
  Future<bool> isLoggedIn();


  

  Future<void> logoutAll();
  Future<void> logout();
  Future<User> registerUser(String email, String pseudo);
  Future<User> getProfile();
  Future<User> updateProfile(String pseudo);
  Future<void> deleteUser();
}
