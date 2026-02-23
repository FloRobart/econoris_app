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
    /* If the request does not require authentication,
       we can skip adding the Authorization header. */
    final requiresAuth = options.extra['authenticated'] != false;
    if (!requiresAuth) {
      handler.next(options);
      return;
    }

    /* If the request requires authentication,
       we need to add the Authorization header. */
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
      return;
    }

    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}
