import 'package:econoris_app/data/services/api/auth/auth_api_client.dart';
import 'package:econoris_app/providers/data/services/api/api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance asynchrone d'[AuthApiClient].
final authApiClientProvider = Provider<AuthApiClient>((ref) {
  return AuthApiClient(apiClient: ref.read(apiClientProvider));
});
