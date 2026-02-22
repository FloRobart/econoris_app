import 'dart:convert';
import 'package:econoris_app/data/services/api/api_client.dart';
import 'package:econoris_app/config/app_config.dart';

/// Auth-specific API wrapper using the shared [DataApiClient] transport.
class AuthApiClient {
  const AuthApiClient({required this.apiClient});

  final ApiClient apiClient;

  static final String _baseUrl = '${AppConfig.authUrl}/users';


  /// Request a login code to be sent to the given email. The server is expected
  /// Return the token associated with the login code, which will be used in the next step of the login process.
  Future<String> requestLoginCode(String email) async {
    final body = {'email': email};

    final response = await apiClient.request(
      HttpMethod.post,
      '$_baseUrl/login/request',
      authenticated: false,
      body: body,
    );

    return jsonDecode(response.data)['token'];
  }

  /// Confirm the login code by sending the email, token, and secret.
  /// The server is expected to return a JWT on successful confirmation.
  /// Return the JWT token if the login is successful. Otherwise, an exception is thrown.
  Future<String> confirmLoginCode(
    String email,
    String token,
    String secret,
  ) async {
    final body = {'email': email, 'token': token, 'secret': secret};

    final response = await apiClient.request(
      HttpMethod.post,
      '$_baseUrl/login/confirm',
      authenticated: false,
      body: body,
    );

    return jsonDecode(response.data)['jwt'];
  }

  /// Logout the user
  Future<void> logout() async {
    final response = await apiClient.request(
      HttpMethod.post,
      '$_baseUrl/logout',
      authenticated: true,
    );

    if (response.statusCode != null && (response.statusCode! < 200 || response.statusCode! >= 300)) {
      throw Exception('Failed to logout');
    }
  }

  /// Register a new user with the given email and pseudo.
  /// The server is expected to return a JWT on successful registration.
  /// Return the JWT token if the registration is successful. Otherwise, an exception is thrown.
  Future<String> registerUser(String email, String pseudo) async {
    final body = {'email': email, 'pseudo': pseudo};

    final response = await apiClient.request(
      HttpMethod.post,
      _baseUrl,
      authenticated: false,
      body: body,
    );

    return jsonDecode(response.data)['jwt'];
  }

  /// Get the current user's profile information.
  /// The server is expected to return the user's profile data if the JWT is valid.
  Future<Map<String, String>> getProfile() async {
    final response = await apiClient.request(
      HttpMethod.get,
      _baseUrl,
      authenticated: true,
    );

    return jsonDecode(response.data);
  }

  /// Update the current user's profile information.
  /// The server is expected to update the user's profile and return the new JWT.
  Future<String> updateUser(String email, String name) async {
    final body = {'email': email, 'name': name};
    final response = await apiClient.request(
      HttpMethod.put,
      _baseUrl,
      authenticated: true,
      body: body,
    );

    return jsonDecode(response.data)['jwt'];
  }

  /// Delete the current user's account.
  /// The server is expected to delete the user's account if the JWT is valid.
  Future<void> deleteUser() async {
    final response = await apiClient.request(
      HttpMethod.delete,
      _baseUrl,
      authenticated: true,
    );

    if (response.statusCode != null && (response.statusCode! < 200 || response.statusCode! >= 300)) {
      throw Exception('Failed to delete user');
    }
  }
}
