import 'dart:convert';
import 'package:econoris_app/data/services/api/api_client.dart';
import 'package:econoris_app/config/app_config.dart';

/// Subscriptions-specific API wrapper using the shared [ApiClient] transport.
class SubscriptionsApiClient {
  static final String _baseUrl = '${AppConfig.dataUrl}/subscriptions';

  /// Get the list of subscriptions for the current user.
  static Future<List<Map<String, dynamic>>> getSubscriptions() async {
    final response = await ApiClient.request(HttpMethod.get, _baseUrl, true);
    return jsonDecode(response.body);
  }

  /// Add a new subscription.
  static Future<Map<String, dynamic>> addSubscription(Map<String, dynamic> body) async {
    final response = await ApiClient.request(HttpMethod.post, _baseUrl, true, body);
    return jsonDecode(response.body);
  }

  /// Update an existing subscription by id.
  static Future<Map<String, dynamic>> updateSubscription(int id,Map<String, dynamic> body) async {
    final response = await ApiClient.request(HttpMethod.put, '$_baseUrl/$id', true, body);
    return jsonDecode(response.body);
  }

  /// Delete a subscription by id.
  static Future<Map<String, dynamic>> deleteSubscription(int id) async {
    final response = await ApiClient.request(HttpMethod.delete, '$_baseUrl/$id', true);
    return jsonDecode(response.body);
  }
}
