import 'package:econoris_app/data/repositories/auth/auth_repository.dart';
import 'package:econoris_app/data/repositories/auth/auth_repository_impl.dart';
import 'package:econoris_app/data/repositories/auth/auth_repository_local.dart';
import 'package:econoris_app/data/repositories/auth/auth_repository_remote.dart';
import 'package:econoris_app/data/services/api/auth_api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fournit une instance asynchrone d'[AuthRepository].
final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final remote = AuthRepositoryRemote();
  final local = AuthRepositoryLocal(AuthApiClient(), prefs);

  return AuthRepositoryImpl(remote: remote, local: local);
});
