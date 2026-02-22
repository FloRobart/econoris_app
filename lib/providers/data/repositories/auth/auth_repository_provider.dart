import 'package:econoris_app/data/repositories/auth/auth_repository.dart';
import 'package:econoris_app/data/repositories/auth/auth_repository_impl.dart';
import 'package:econoris_app/data/repositories/auth/auth_repository_local.dart';
import 'package:econoris_app/data/repositories/auth/auth_repository_remote.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance asynchrone d'[AuthRepository].
final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final remote = AuthRepositoryRemote();
  final local = AuthRepositoryLocal();

  return AuthRepositoryImpl(remote: remote, local: local);
});
