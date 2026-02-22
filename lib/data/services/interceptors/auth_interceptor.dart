import 'package:dio/dio.dart';

/// Dio interceptor that injects the bearer token and refreshes it on demand.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.getJwt});

  final String? Function() getJwt;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers.containsKey('Authorization')) {
      handler.next(options);
      return;
    }

    final token = getJwt();

    if (token == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: 'AuthInterceptor: Access token NULL',
        ),
      );
    }

    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}
