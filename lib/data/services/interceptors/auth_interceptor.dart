import 'package:dio/dio.dart';
import 'package:econoris_app/data/services/auth/auth_notifier.dart';

/// Dio interceptor that injects the bearer token and refreshes it on demand.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.authNotifier});

  final AuthNotifier authNotifier;

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

    /* If the user is not authenticated, we reject the request with an error. */
    if (!authNotifier.isAuthenticated) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: 'AuthInterceptor: User not authenticated',
        ),
      );
      return;
    }

    /* If the user is authenticated, we add the Authorization header with the JWT. */
    final token = authNotifier.getJwt;
    if (token == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: 'AuthInterceptor: JWT NULL',
        ),
      );
      return;
    }

    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}
