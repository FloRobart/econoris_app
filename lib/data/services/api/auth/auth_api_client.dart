import 'package:econoris_app/data/services/api/api_client.dart';
import 'package:econoris_app/config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance asynchrone d'[AuthApiClient].
final authApiClientProvider = Provider<AuthApiClient>((ref) {
  return AuthApiClient(apiClient: ref.read(apiClientProvider));
});

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

    return response.data['token'];
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

    return response.data['jwt'];
  }

  /// Logout the user
  Future<void> logout() async {
    final response = await apiClient.request(
      HttpMethod.post,
      '$_baseUrl/logout',
      authenticated: true,
    );

    if (response.statusCode != null &&
        (response.statusCode! < 200 || response.statusCode! >= 300)) {
      throw Exception('Failed to logout');
    }
  }
}
