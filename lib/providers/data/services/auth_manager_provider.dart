import 'package:econoris_app/data/services/auth_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance asynchrone d'[AuthManager].
final authManagerProvider = Provider<AuthManager>((ref) {
  return AuthManager.instance;
});
