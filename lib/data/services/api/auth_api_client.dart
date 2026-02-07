import 'package:http/http.dart' as http;

import 'api_client.dart';

/// Auth-specific API wrapper using the shared [ApiClient] transport.
class AuthApiClient {
  /// Request a login code for the provided email.
  static Future<http.Response> requestLoginCode(String email) {
    return ApiClient.requestLoginCode(email);
  }

  /// Confirm a login code for the given email.
  static Future<http.Response> confirmLoginCode(
    String email,
    String token,
    String secret,
  ) {
    return ApiClient.confirmLoginCode(email, token, secret);
  }

  /// Register a user by email and optional pseudo.
  static Future<http.Response> registerUser(String email, [String? pseudo]) {
    return ApiClient.registerUser(email, pseudo);
  }

  /// Fetch the user profile for the current session.
  static Future<http.Response> getProfile(String jwt) {
    return ApiClient.getProfile(jwt);
  }

  /// Log out the current user.
  static Future<http.Response> logout(String jwt) {
    return ApiClient.logout(jwt);
  }

  /// Delete the current user account.
  static Future<http.Response> deleteUser(String jwt) {
    return ApiClient.deleteUser(jwt);
  }

  /// Update the current user's email and name.
  static Future<http.Response> updateUser(
    String jwt,
    String email,
    String name,
  ) {
    return ApiClient.updateUser(jwt, email, name);
  }
}
