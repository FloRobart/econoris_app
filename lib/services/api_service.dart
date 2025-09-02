import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiService {
  static Future<http.Response> requestLoginCode(String email, String name) {
    final url = Uri.parse('${Config.floraccessServer}/code/login/request');
    return http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'name': name}));
  }

  static Future<http.Response> confirmLoginCode(String email, String code) {
    final url = Uri.parse('${Config.floraccessServer}/code/login/confirm');
    return http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}));
  }

  static Future<http.Response> getProfile(String jwt) {
    final url = Uri.parse('${Config.floraccessServer}/user/profile');
    return http.get(url, headers: {'Authorization': 'Bearer $jwt'});
  }

  static Future<http.Response> logout(String jwt) {
    final url = Uri.parse('${Config.floraccessServer}/user/logout');
    return http.post(url, headers: {'Authorization': 'Bearer $jwt'});
  }

  static Future<http.Response> deleteUser(String jwt) {
    final url = Uri.parse('${Config.floraccessServer}/user');
    return http.delete(url, headers: {'Authorization': 'Bearer $jwt'});
  }

  static Future<http.Response> updateUser(String jwt, String email, String name) {
    final url = Uri.parse('${Config.floraccessServer}/user');
    return http.put(url,
        headers: {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'name': name}));
  }

  static Future<http.Response> getOperations(String jwt) {
    final url = Uri.parse('${Config.econorisServer}/operations');
    return http.get(url, headers: {'Authorization': 'Bearer $jwt'});
  }

  static Future<http.Response> addOperation(String jwt, Map<String, dynamic> body) {
    final url = Uri.parse('${Config.econorisServer}/operations');
    return http.post(url,
        headers: {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'},
        body: jsonEncode({'operation': body}));
  }

  static Future<http.Response> updateOperation(String jwt, int id, Map<String, dynamic> body) {
    final url = Uri.parse('${Config.econorisServer}/operations/id/$id');
    return http.put(url,
        headers: {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'},
        body: jsonEncode({'operation': body}));
  }

  static Future<http.Response> deleteOperation(String jwt, int id) {
    final url = Uri.parse('${Config.econorisServer}/operations/id/$id');
    return http.delete(url, headers: {'Authorization': 'Bearer $jwt'});
  }
}