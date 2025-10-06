import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_manager.dart';

class ApiService {
  static Future<http.Response> requestLoginCode(String email, [String? name]) {
    final url = Uri.parse('${Config.floraccessServer}/code/login/request');
    final body = <String, dynamic>{'email': email};
    if (name != null && name.isNotEmpty) body['name'] = name;
    return http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body));
  }

  static Future<http.Response> confirmLoginCode(String email, String code) {
    final url = Uri.parse('${Config.floraccessServer}/code/login/confirm');
    return http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}));
  }

  // Register a user by email. The server is expected to return a JWT on
  // successful registration so the client can log the user in immediately.
  static Future<http.Response> registerUser(String email, [String? name]) {
    final url = Uri.parse('${Config.floraccessServer}/user/register');
    final body = <String, dynamic>{'email': email};
    if (name != null && name.isNotEmpty) body['name'] = name;
    return http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body));
  }

  static Future<http.Response> getProfile(String jwt) {
    final url = Uri.parse('${Config.floraccessServer}/user/profile');
  return _wrap(http.get(url, headers: {'Authorization': 'Bearer $jwt'}));
  }

  static Future<http.Response> logout(String jwt) {
    final url = Uri.parse('${Config.floraccessServer}/user/logout');
  return _wrap(http.post(url, headers: {'Authorization': 'Bearer $jwt'}));
  }

  static Future<http.Response> deleteUser(String jwt) {
    final url = Uri.parse('${Config.floraccessServer}/user');
  return _wrap(http.delete(url, headers: {'Authorization': 'Bearer $jwt'}));
  }

  static Future<http.Response> updateUser(String jwt, String email, String name) {
    final url = Uri.parse('${Config.floraccessServer}/user');
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
    body: jsonEncode({'operation': body})));
  }

  static Future<http.Response> updateOperation(String jwt, Map<String, dynamic> body) {
    final url = Uri.parse('${Config.econorisServer}/operations');
  return _wrap(http.put(url,
    headers: {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'},
    body: jsonEncode({'operation': body})));
  }

  static Future<http.Response> deleteOperation(String jwt, int id) {
    final url = Uri.parse('${Config.econorisServer}/operations/id/$id');
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