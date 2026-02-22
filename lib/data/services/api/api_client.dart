import 'dart:convert';
import 'package:dio/dio.dart';

enum HttpMethod { get, post, put, delete }

/// A simple API client that wraps http requests. This is a very basic implementation and can be extended with features like error handling, logging, etc.
class ApiClient {
  const ApiClient({required Dio dio}): _dio = dio;

  final Dio _dio;


  /// A helper method to wrap http requests and handle common logic like adding the Authorization header and checking for 401 responses.
  Future<Response> request(
    HttpMethod method,
    String url, {
    bool authenticated = true,
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    Response response;
    String stringUri = Uri.parse(url).toString();

    try {
      switch (method) {
        case HttpMethod.get:
          response = await _dio.get(
            stringUri,
            queryParameters: queryParameters,
          );
          break;
        case HttpMethod.post:
          response = await _dio.post(
            stringUri,
            data: jsonEncode(body),
            queryParameters: queryParameters,
          );
          break;
        case HttpMethod.put:
          response = await _dio.put(
            stringUri,
            data: jsonEncode(body),
            queryParameters: queryParameters,
          );
          break;
        case HttpMethod.delete:
          response = await _dio.delete(
            stringUri,
            queryParameters: queryParameters,
            data: jsonEncode(body),
          );
          break;
      }
    } catch (e) {
      throw Exception('Failed to make authenticated request: $e');
    }

    return response;
  }
}
