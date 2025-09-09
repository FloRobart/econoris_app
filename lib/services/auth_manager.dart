import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple singleton to broadcast session invalidation (eg. on 401)
class AuthManager {
  AuthManager._internal();
  static final AuthManager _instance = AuthManager._internal();
  static AuthManager get instance => _instance;

  /// When true, listeners should force the user to the login page.
  final ValueNotifier<bool> sessionInvalidated = ValueNotifier(false);

  Future<void> invalidateSession() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('jwt');
    // notify listeners
    sessionInvalidated.value = true;
  }
}
