import 'package:flutter/widgets.dart';
// shared_preferences removed; RootRouter handles token removal

/// Simple singleton to broadcast session invalidation (eg. on 401)
class AuthManager {
  AuthManager._internal();
  static final AuthManager _instance = AuthManager._internal();
  static AuthManager get instance => _instance;

  /// When true, listeners should force the user to the login page.
  final ValueNotifier<bool> sessionInvalidated = ValueNotifier(false);

  Future<void> invalidateSession() async {
    // only notify listeners; do not remove jwt here.
    // RootRouter will remove the token and perform navigation.
    sessionInvalidated.value = true;
  }
}
