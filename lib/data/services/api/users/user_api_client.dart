import 'package:econoris_app/config/app_config.dart';
import 'package:econoris_app/data/services/api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance asynchrone d'[UserApiClient].
final userApiClientProvider = Provider<UserApiClient>((ref) {
  return UserApiClient(apiClient: ref.read(apiClientProvider));
});

/// User-specific API wrapper using the shared [ApiClient] transport.
class UserApiClient {
  const UserApiClient({required this.apiClient});

  final ApiClient apiClient;

  static final String _baseUrl = '${AppConfig.authUrl}/users';

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await apiClient.request(HttpMethod.get, _baseUrl);
    return response.data;
  }

  Future<void> logoutAll() async {
    await apiClient.request(HttpMethod.post, '$_baseUrl/logout');
  }
}
