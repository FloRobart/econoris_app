import 'package:econoris_app/data/services/api/api_client.dart';
import 'package:http/http.dart' as http;

import 'package:econoris_app/config/app_config.dart';

/// Operations-specific API wrapper using the shared [ApiClient] transport.
class OperationsApiClient {
  static final String _baseUrl = '${AppConfig.dataUrl}/operations';

  /// Get the list of operations for the current user.
  /// The server is expected to return a list of operations if the JWT is valid.
  static Future<http.Response> getOperations() {
    return ApiClient.request(HttpMethod.get, _baseUrl, true);
  }

  /// Add a new operation.
  /// The server is expected to return the created operation with its id if the JWT is valid and the request body is correct.
  static Future<http.Response> addOperation(Map<String, dynamic> body) {
    return ApiClient.request(HttpMethod.post, _baseUrl, true, body);
  }

  /// Update an existing operation by id.
  /// The server is expected to return the updated operation if the JWT is valid and the request body is correct.
  static Future<http.Response> updateOperation(int id, Map<String, dynamic> body) {
    return ApiClient.request(HttpMethod.put, '$_baseUrl/$id', true, body);
  }

  /// Delete an operation by id.
  /// The server expects DELETE /operations/{operation_id}.
  static Future<http.Response> deleteOperation(int id) {
    return ApiClient.request(HttpMethod.delete, '$_baseUrl/$id', true);
  }
}
