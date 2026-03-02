import 'package:econoris_app/domain/models/users/user.dart';

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
