import 'package:econoris_app/data/services/api/auth/auth_api_client.dart';

class AuthRepositoryRemote {
  const AuthRepositoryRemote({required this.authApiClient});

  final AuthApiClient authApiClient;

  /// Requests a login code to be sent to the user's email.
  /// Returns the token associated with the login code.
  Future<String> requestLoginCode(String email) async {
    return await authApiClient.requestLoginCode(email);
  }

  /// Confirms the login code and retrieves the JWT token.
  /// Returns the JWT token if the login is successful.
  Future<String> confirmLoginCode(
    String email,
    String token,
    String secret,
  ) async {
    return await authApiClient.confirmLoginCode(email, token, secret);
  }

  /// Logs out the user by invalidating the JWT token.
  /// This logout user from the all devices and all applications.
  Future<void> logout() async {
    await authApiClient.logout();
  }
}