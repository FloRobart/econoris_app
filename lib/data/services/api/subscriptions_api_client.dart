import 'package:econoris_app/data/services/api/api_client.dart';
import 'package:http/http.dart' as http;

import 'package:econoris_app/config/app_config.dart';

/// Subscriptions-specific API wrapper using the shared [ApiClient] transport.
class SubscriptionsApiClient {
  static final String _baseUrl = '${AppConfig.dataUrl}/subscriptions';

  /// Get the list of subscriptions for the current user.
  static Future<http.Response> getSubscriptions() {
    return ApiClient.request(HttpMethod.get, _baseUrl, true);
  }

  /// Add a new subscription.
  static Future<http.Response> addSubscription(Map<String, dynamic> body) {
    return ApiClient.request(HttpMethod.post, _baseUrl, true, body);
  }

  /// Update an existing subscription by id.
  static Future<http.Response> updateSubscription(int id, Map<String, dynamic> body) {
    return ApiClient.request(HttpMethod.put, '$_baseUrl/$id', true, body);
  }

  /// Delete a subscription by id.
  static Future<http.Response> deleteSubscription(int id) {
    return ApiClient.request(HttpMethod.delete, '$_baseUrl/$id', true);
  }
}
