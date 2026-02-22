import 'dart:convert';
import 'package:econoris_app/data/services/api/api_client.dart';
import 'package:econoris_app/config/app_config.dart';

/// Subscriptions-specific API wrapper using the shared [ApiClient] transport.
class SubscriptionApiClient {
  const SubscriptionApiClient({required this.apiClient});

  final ApiClient apiClient;

  static final String _baseUrl = '${AppConfig.dataUrl}/subscriptions';

  /// Get the list of subscriptions for the current user.
  Future<List<Map<String, dynamic>>> getSubscriptions() async {
    final response = await apiClient.request(HttpMethod.get, _baseUrl, authenticated: true);
    return jsonDecode(response.data);
  }

  /// Add a new subscription.
  Future<Map<String, dynamic>> addSubscription(Map<String, dynamic> body) async {
    final response = await apiClient.request(HttpMethod.post, _baseUrl, authenticated: true, body: body);
    return jsonDecode(response.data);
  }

  /// Update an existing subscription by id.
  Future<Map<String, dynamic>> updateSubscription(int id,Map<String, dynamic> body) async {
    final response = await apiClient.request(HttpMethod.put, '$_baseUrl/$id', authenticated: true, body: body);
    return jsonDecode(response.data);
  }

  /// Delete a subscription by id.
  Future<Map<String, dynamic>> deleteSubscription(int id) async {
    final response = await apiClient.request(HttpMethod.delete, '$_baseUrl/$id', authenticated: true);
    return jsonDecode(response.data);
  }
}
