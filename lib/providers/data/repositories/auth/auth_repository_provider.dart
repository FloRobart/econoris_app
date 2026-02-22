import 'package:econoris_app/data/repositories/auth/auth_repository.dart';
import 'package:econoris_app/data/repositories/auth/auth_repository_impl.dart';
import 'package:econoris_app/data/repositories/auth/auth_repository_local.dart';
import 'package:econoris_app/data/repositories/auth/auth_repository_remote.dart';
import 'package:econoris_app/providers/data/services/api/auth/auth_api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance asynchrone d'[AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = AuthRepositoryRemote(authApiClient: ref.read(authApiClientProvider));
  final local = AuthRepositoryLocal();

  return AuthRepositoryImpl(remote: remote, local: local);
});
