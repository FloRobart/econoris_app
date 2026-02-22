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
    bool requiresAuth, [
    Map<String, dynamic>? body,
  ]) async {
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
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case HttpMethod.put:
          response = await http.put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
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
// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:genesis/data/services/interceptors/auth_interceptor.dart';
// import 'package:genesis/providers/auth/auth_provider.dart';

// enum HttpMethod { get, post, put, delete }

// /// A simple API client that wraps http requests. This is a very basic implementation and can be extended with features like error handling, logging, etc.
// class ApiClient {
//   final Ref ref;

//   late final Dio _dio = init();

//   ApiClient(this.ref);

//   Dio init() {
//     final oidcUserManager = ref.watch(oidcUserManagerProvider);

//     Dio localDio = Dio()
//       ..interceptors.add(LogInterceptor(requestBody: true, responseBody: true))
//       ..interceptors.add(AuthInterceptor(oidcUserManager: oidcUserManager));

//     return localDio;
//   }

//   /// A helper method to wrap http requests and handle common logic like adding the Authorization header and checking for 401 responses.
//   Future<Response> request(
//     HttpMethod method,
//     String url, {
//     Map<String, dynamic>? body,
//     Map<String, String>? queryParameters,
//   }) async {
//     Response response;
//     String stringUri = Uri.parse(url).toString();

//     try {
//       switch (method) {
//         case HttpMethod.get:
//           response = await _dio.get(
//             stringUri,
//             queryParameters: queryParameters,
//           );
//           break;
//         case HttpMethod.post:
//           response = await _dio.post(
//             stringUri,
//             data: jsonEncode(body),
//             queryParameters: queryParameters,
//           );
//           break;
//         case HttpMethod.put:
//           response = await _dio.put(
//             stringUri,
//             data: jsonEncode(body),
//             queryParameters: queryParameters,
//           );
//           break;
//         case HttpMethod.delete:
//           response = await _dio.delete(
//             stringUri,
//             queryParameters: queryParameters,
//             data: jsonEncode(body),
//           );
//           break;
//       }
//     } catch (e) {
//       throw Exception('Failed to make authenticated request: $e');
//     }

//     return response;
//   }
// }