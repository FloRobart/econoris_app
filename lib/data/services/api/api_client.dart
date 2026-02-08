import 'dart:convert';

import 'package:econoris_app/data/services/auth_manager.dart';
import 'package:http/http.dart' as http;

enum HttpMethod { get, post, put, delete }

/// A simple API client that wraps http requests. This is a very basic implementation and can be extended with features like error handling, logging, etc.
class ApiClient {
  /// A helper method to wrap http requests and handle common logic like adding the Authorization header and checking for 401 responses.
  static Future<http.Response> request(
    HttpMethod method,
    String url,
    bool requiresAuth,
    [Map<String, dynamic>? body]
  ) async {
    http.Response response;
    Uri uri = Uri.parse(url);
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (requiresAuth) 'Authorization': 'Bearer ${AuthManager.instance.jwt}',
    };

    try {
      switch (method) {
        case HttpMethod.get:
          response = await http.get(uri, headers: headers);
          break;
        case HttpMethod.post:
          response = await http.post(uri, headers: headers, body: jsonEncode(body));
          break;
        case HttpMethod.put:
          response = await http.put(uri, headers: headers, body: jsonEncode(body));
          break;
        case HttpMethod.delete:
          response = await http.delete(uri, headers: headers);
          break;
      }
    } catch (e) {
      throw Exception('Failed to make authenticated request: $e');
    }

    if (response.statusCode == 401) {
      AuthManager.instance.removeJwt();
    }

    return response;
  }
}
