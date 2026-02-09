import 'dart:convert';

import 'package:econoris_app/data/services/api/api_client.dart';
import 'package:http/http.dart' as http;

import 'package:econoris_app/config/app_config.dart';

/// Auth-specific API wrapper using the shared [DataApiClient] transport.
class AuthApiClient {
  static final String _baseUrl = '${AppConfig.authUrl}/users';

  /// Request a login code to be sent to the given email. The server is expected
  /// Return the token associated with the login code, which will be used in the next step of the login process.
  static Future<String> requestLoginCode(String email) async {
    final body = {'email': email};

    final http.Response response = await ApiClient.request(
      HttpMethod.post,
      '$_baseUrl/login/request',
      false,
      body,
    );

    return jsonDecode(response.body)['token'];
  }

  /// Confirm the login code by sending the email, token, and secret.
  /// The server is expected to return a JWT on successful confirmation.
  /// Return the JWT token if the login is successful. Otherwise, an exception is thrown.
  static Future<String> confirmLoginCode(String email, String token, String secret) async {
    final body = {'email': email, 'token': token, 'secret': secret};

    final http.Response response = await ApiClient.request(
      HttpMethod.post,
      '$_baseUrl/login/confirm',
      false,
      body,
    );

    return jsonDecode(response.body)['jwt'];
  }

  /// Logout the user
  static Future<void> logout() async {
    final http.Response response = await ApiClient.request(
      HttpMethod.post,
      '$_baseUrl/logout',
      true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to logout');
    }
  }

  /// Register a new user with the given email and pseudo.
  /// The server is expected to return a JWT on successful registration.
  /// Return the JWT token if the registration is successful. Otherwise, an exception is thrown.
  static Future<String> registerUser(String email, String pseudo) async {
    final body = {'email': email, 'pseudo': pseudo};

    final http.Response response = await ApiClient.request(
      HttpMethod.post,
      _baseUrl,
      false,
      body,
    );

    return jsonDecode(response.body)['jwt'];
  }

  /// Get the current user's profile information.
  /// The server is expected to return the user's profile data if the JWT is valid.
  static Future<Map<String, String>> getProfile() async {
    final http.Response response = await ApiClient.request(
      HttpMethod.get,
      _baseUrl,
      true,
    );

    return jsonDecode(response.body);
  }

  /// Update the current user's profile information.
  /// The server is expected to update the user's profile and return the new JWT.
  static Future<String> updateUser(String email, String name) async {
    final body = {'email': email, 'name': name};
    final http.Response response = await ApiClient.request(
      HttpMethod.put,
      _baseUrl,
      true,
      body,
    );

    return jsonDecode(response.body)['jwt'];
  }

  /// Delete the current user's account.
  /// The server is expected to delete the user's account if the JWT is valid.
  static Future<void> deleteUser() async {
    final http.Response response = await ApiClient.request(
      HttpMethod.delete,
      _baseUrl,
      true,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete user');
    }
  }
}
