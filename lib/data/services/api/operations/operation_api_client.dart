import 'dart:convert';
import 'package:econoris_app/data/services/api/api_client.dart';
import 'package:econoris_app/config/app_config.dart';

/// Operations-specific API wrapper using the shared [ApiClient] transport.
class OperationApiClient {
  const OperationApiClient({required this.apiClient});

  final ApiClient apiClient;

  static final String _baseUrl = '${AppConfig.dataUrl}/operations';

  /// Get the list of operations for the current user.
  /// The server is expected to return a list of operations if the JWT is valid.
  Future<List<Map<String, dynamic>>> getOperations() async {
    final response = await apiClient.request(HttpMethod.get, _baseUrl, authenticated: true);
    return jsonDecode(response.data);
  }

  /// Add a new operation.
  /// The server is expected to return the created operation with its id if the JWT is valid and the request body is correct.
  Future<Map<String, dynamic>> addOperation(Map<String, dynamic> body) async {
    final response = await apiClient.request(HttpMethod.post, _baseUrl, authenticated: true, body: body);
    return jsonDecode(response.data);
  }

  /// Update an existing operation by id.
  /// The server is expected to return the updated operation if the JWT is valid and the request body is correct.
  Future<Map<String, dynamic>> updateOperation(int id, Map<String, dynamic> body) async {
    final response = await apiClient.request(HttpMethod.put, '$_baseUrl/$id', authenticated: true, body: body);
    return jsonDecode(response.data);
  }

  /// Delete an operation by id.
  /// The server expects DELETE /operations/{operation_id}.
  Future<Map<String, dynamic>> deleteOperation(int id) async {
    final response = await apiClient.request(HttpMethod.delete, '$_baseUrl/$id', authenticated: true);
    return jsonDecode(response.data);
  }
}
