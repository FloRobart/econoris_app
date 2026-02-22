import 'package:econoris_app/data/services/api/api_client.dart';
import 'package:econoris_app/providers/data/services/api/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance asynchrone d'[ApiClient].
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(dio: ref.read(dioProvider));
});
