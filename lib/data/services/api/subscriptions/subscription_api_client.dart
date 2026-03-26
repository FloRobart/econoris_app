import 'dart:convert';
import 'package:econoris_app/data/services/api/api_client.dart';
import 'package:econoris_app/config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance asynchrone d'[SubscriptionApiClient].
final subscriptionApiClientProvider = Provider<SubscriptionApiClient>((ref) {
  return SubscriptionApiClient(apiClient: ref.read(apiClientProvider));
});

/// Subscriptions-specific API wrapper using the shared [ApiClient] transport.
class SubscriptionApiClient {
  const SubscriptionApiClient({required this.apiClient});

  final ApiClient apiClient;

  static final String _baseUrl = '${AppConfig.dataUrl}/subscriptions';

  /// Get the list of subscriptions for the current user.
  /// The server is expected to return a list of subscriptions if the JWT is valid.
  Future<List<Map<String, dynamic>>> getSubscriptions() async {
    final response = await apiClient.request(
      HttpMethod.get,
      _baseUrl,
      authenticated: true,
    );

    final dynamic rawData = response.data;

    if (rawData is String) {
      final decoded = jsonDecode(rawData);
      if (decoded is List) {
        return decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
    }

    if (rawData is List) {
      return rawData
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }

    throw FormatException(
      'Unexpected subscriptions payload type: ${rawData.runtimeType}',
    );
  }

  /// Add a new subscription.
  /// The server is expected to return the created subscription with its id if the JWT is valid and the request body is correct.
  Future<Map<String, dynamic>> addSubscription(
    Map<String, dynamic> body,
  ) async {
    final response = await apiClient.request(
      HttpMethod.post,
      _baseUrl,
      authenticated: true,
      body: body,
    );
    return response.data;
  }

  /// Update an existing subscription by id.
  /// The server is expected to return the updated subscription if the JWT is valid and the request body is correct.
  Future<Map<String, dynamic>> updateSubscription(
    int id,
    Map<String, dynamic> body,
  ) async {
    final response = await apiClient.request(
      HttpMethod.put,
      '$_baseUrl/$id',
      authenticated: true,
      body: body,
    );
    return response.data;
  }

  /// Delete an subscription by id.
  /// The server expects DELETE /subscriptions/{subscription_id}.
  Future<Map<String, dynamic>> deleteSubscription(int id) async {
    final response = await apiClient.request(
      HttpMethod.delete,
      '$_baseUrl/$id',
      authenticated: true,
    );
    return response.data;
  }

  // /// Get the list of subscriptions for the current user.
  // Future<List<Map<String, dynamic>>> getSubscriptions() async {
  //   final response = await apiClient.request(HttpMethod.get, _baseUrl, authenticated: true);
  //   return jsonDecode(response.data);
  // }

  // /// Add a new subscription.
  // Future<Map<String, dynamic>> addSubscription(Map<String, dynamic> body) async {
  //   final response = await apiClient.request(HttpMethod.post, _baseUrl, authenticated: true, body: body);
  //   return jsonDecode(response.data);
  // }

  // /// Update an existing subscription by id.
  // Future<Map<String, dynamic>> updateSubscription(int id,Map<String, dynamic> body) async {
  //   final response = await apiClient.request(HttpMethod.put, '$_baseUrl/$id', authenticated: true, body: body);
  //   return jsonDecode(response.data);
  // }

  // /// Delete a subscription by id.
  // Future<Map<String, dynamic>> deleteSubscription(int id) async {
  //   final response = await apiClient.request(HttpMethod.delete, '$_baseUrl/$id', authenticated: true);
  //   return jsonDecode(response.data);
  // }
}
