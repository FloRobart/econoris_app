import 'package:dio/dio.dart';
import 'package:econoris_app/config/app_config.dart';
import 'package:econoris_app/data/services/interceptors/auth_interceptor.dart';
import 'package:econoris_app/providers/data/services/auth_manager_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: AppConfig.dataUrl));
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  dio.interceptors.add(AuthInterceptor(getJwt: ref.watch(authManagerProvider).getJwt));

  return dio;
});