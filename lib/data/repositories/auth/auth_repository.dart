import 'package:econoris_app/domain/models/auth/profile.dart';

/// Repository interface for authentication operations.
abstract class AuthRepository {
  Future<void> requestLoginCode(String email);
  Future<void> confirmLoginCode(String secret);
  Future<void> logoutAll();
  Future<void> logout();
  Future<Profile> registerUser(String email, String pseudo);
  Future<Profile> getProfile();
  Future<Profile> updateProfile(String pseudo);
  Future<void> deleteUser();
  Future<String?> getEmail();
}
