import 'package:econoris_app/data/models/auth/profile_dto.dart';
import 'package:econoris_app/data/services/api/auth_api_client.dart';

class AuthRepositoryRemote {
  /// Requests a login code to be sent to the user's email.
  /// Returns the token associated with the login code.
  Future<String> requestLoginCode(String email) async {
    return await AuthApiClient.requestLoginCode(email);
  }

  /// Confirms the login code and retrieves the JWT token.
  /// Returns the JWT token if the login is successful.
  Future<String> confirmLoginCode(String email, String token, String secret) async {
    return await AuthApiClient.confirmLoginCode(email, token, secret);
  }

  /// Logs out the user by invalidating the JWT token.
  /// This logout user from the all devices and all applications.
  Future<void> logout() async {
    await AuthApiClient.logout();
  }

  /// Registers a new user with the provided email and pseudo.
  /// Returns the JWT token if the registration is successful.
  Future<String> registerUser(String email, String pseudo) async {
    return await AuthApiClient.registerUser(email, pseudo);
  }

  /// Retrieves the user's profile information.
  /// Returns a [ProfileDto] containing the user's profile data.
  Future<ProfileDto> getProfile() async {
    final Map<String, dynamic> response = await AuthApiClient.getProfile();
    return ProfileDto.fromJson(response);
  }

  /// Updates the user's profile with the provided pseudo.
  /// Returns the new JWT token if the update is successful.
  Future<String> updateProfile(String email, String pseudo) async {
    return await AuthApiClient.updateUser(email, pseudo);
  }

  /// Deletes the user's account.
  Future<void> deleteUser() async {
    await AuthApiClient.deleteUser();
  }
}
