import 'package:econoris_app/data/services/api/api_client.dart';
import 'package:http/http.dart' as http;

import 'package:econoris_app/config/app_config.dart';

/// Auth-specific API wrapper using the shared [DataApiClient] transport.
class AuthApiClient {
  static final String _baseUrl = AppConfig.authUrl;

  /// Request a login code to be sent to the given email. The server is expected
  static Future<http.Response> requestLoginCode(String email) {
    final body = {'email': email};

    return ApiClient.request(
      HttpMethod.post,
      '$_baseUrl/users/login/request',
      false,
      body,
    );
  }

  /// Confirm the login code by sending the email, token, and secret.
  /// The server is expected to return a JWT on successful confirmation.
  static Future<http.Response> confirmLoginCode(String email, String token, String secret) {
    final body = {'email': email, 'token': token, 'secret': secret};

    return ApiClient.request(
      HttpMethod.post,
      '$_baseUrl/users/login/confirm',
      false,
      body,
    );
  }

  /// Logout the user
  static Future<http.Response> logout(String jwt) {
    return ApiClient.request(
      HttpMethod.post,
      '$_baseUrl/users/logout',
      true,
    );
  }

  /// Register a new user with the given email and pseudo.
  /// The server is expected to return a JWT on successful registration.
  static Future<http.Response> registerUser(String email, String pseudo) {
    final body = {'email': email, 'pseudo': pseudo};

    return ApiClient.request(
      HttpMethod.post,
      '$_baseUrl/users',
      false,
      body,
    );
  }

  /// Get the current user's profile information.
  /// The server is expected to return the user's profile data if the JWT is valid.
  static Future<http.Response> getProfile(String jwt) {
    return ApiClient.request(
      HttpMethod.get,
      '$_baseUrl/users',
      true,
    );
  }

  /// Update the current user's profile information.
  /// The server is expected to update the user's profile and return the new JWT.
  static Future<http.Response> updateUser(String jwt, String email, String name) {
    final body = {'email': email, 'name': name};
    return ApiClient.request(
      HttpMethod.put,
      '$_baseUrl/users',
      true,
      body,
    );
  }

  /// Delete the current user's account.
  /// The server is expected to delete the user's account if the JWT is valid.
  static Future<http.Response> deleteUser(String jwt) {
    return ApiClient.request(
      HttpMethod.delete,
      '$_baseUrl/users',
      true,
    );
  }
}
