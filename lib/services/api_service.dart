import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_manager.dart';

class ApiService {
  static Future<http.Response> requestLoginCode(String email) {
    final url = Uri.parse('${Config.floraccessServer}/users/login/request');
    final body = <String, dynamic>{'email': email};
    return http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body));
  }

  // Confirm a login using the token previously received from requestLoginCode
  // and the secret (code) entered by the user. The server expects an object
  // { email, token, secret } and will reply with the final JWT on success.
  static Future<http.Response> confirmLoginCode(String email, String token, String secret) {
    final url = Uri.parse('${Config.floraccessServer}/users/login/confirm');
    return http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'token': token, 'secret': secret}));
  }

  // Register a user by email. The server is expected to return a JWT on
  // successful registration so the client can log the user in immediately.
  static Future<http.Response> registerUser(String email, [String? pseudo]) {
    final url = Uri.parse('${Config.floraccessServer}/users');
    final body = <String, dynamic>{'email': email};
    if (pseudo != null && pseudo.isNotEmpty) body['pseudo'] = pseudo;
    return http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body));
  }

  static Future<http.Response> getProfile(String jwt) {
    final url = Uri.parse('${Config.floraccessServer}/users');
  return _wrap(http.get(url, headers: {'Authorization': 'Bearer $jwt'}));
  }

  static Future<http.Response> logout(String jwt) {
    final url = Uri.parse('${Config.floraccessServer}/users/logout');
  return _wrap(http.post(url, headers: {'Authorization': 'Bearer $jwt'}));
  }

  static Future<http.Response> deleteUser(String jwt) {
    final url = Uri.parse('${Config.floraccessServer}/users');
  return _wrap(http.delete(url, headers: {'Authorization': 'Bearer $jwt'}));
  }

  static Future<http.Response> updateUser(String jwt, String email, String name) {
    final url = Uri.parse('${Config.floraccessServer}/users');
  return _wrap(http.put(url,
    headers: {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'name': name})));
  }

  static Future<http.Response> getOperations(String jwt) {
    final url = Uri.parse('${Config.econorisServer}/operations');
  return _wrap(http.get(url, headers: {'Authorization': 'Bearer $jwt'}));
  }

  static Future<http.Response> addOperation(String jwt, Map<String, dynamic> body) {
    final url = Uri.parse('${Config.econorisServer}/operations');
  return _wrap(http.post(url,
    headers: {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'},
    body: jsonEncode(body)));
  }

  // Update an operation by id. The server expects PUT /operations/{operation_id}
  // with the operation object as the body.
  static Future<http.Response> updateOperation(String jwt, int operationId, Map<String, dynamic> body) {
    final url = Uri.parse('${Config.econorisServer}/operations/$operationId');
    return _wrap(http.put(url,
      headers: {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'},
      body: jsonEncode(body)));
  }

  static Future<http.Response> deleteOperation(String jwt, int id) {
    final url = Uri.parse('${Config.econorisServer}/operations/$id');
    return _wrap(http.delete(url, headers: {'Authorization': 'Bearer $jwt'}));
  }

  // Subscriptions endpoints
  static Future<http.Response> getSubscriptions(String jwt) {
    final url = Uri.parse('${Config.econorisServer}/subscriptions');
    return _wrap(http.get(url, headers: {'Authorization': 'Bearer $jwt'}));
  }

  static Future<http.Response> addSubscription(String jwt, Map<String, dynamic> body) {
    final url = Uri.parse('${Config.econorisServer}/subscriptions');
    return _wrap(http.post(url,
      headers: {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'},
      body: jsonEncode(body)));
  }

  static Future<http.Response> updateSubscription(String jwt, int subscriptionId, Map<String, dynamic> body) {
    final url = Uri.parse('${Config.econorisServer}/subscriptions/$subscriptionId');
    return _wrap(http.put(url,
      headers: {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'},
      body: jsonEncode(body)));
  }

  static Future<http.Response> deleteSubscription(String jwt, int subscriptionId) {
    final url = Uri.parse('${Config.econorisServer}/subscriptions/$subscriptionId');
    return _wrap(http.delete(url, headers: {'Authorization': 'Bearer $jwt'}));
  }

  static Future<http.Response> _wrap(Future<http.Response> future) async {
    try {
      final resp = await future;
      if (resp.statusCode == 401) {
        // invalidate session globally
        await AuthManager.instance.invalidateSession();
      }
      return resp;
    } catch (e) {
      rethrow;
    }
  }
}