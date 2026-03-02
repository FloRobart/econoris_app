import 'package:econoris_app/config/shared_preferences_keys.dart';
import 'package:econoris_app/domain/models/users/user.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Fournit une instance asynchrone d'[AuthManager].
final authManagerProvider = Provider<AuthManager>((ref) {
  return AuthManager.instance;
});

/// Singleton class to manage authentication state, including JWT storage and session invalidation.
class AuthManager {
  /// Private constructor for singleton pattern.
  AuthManager._private();

  /// The API client for authentication-related network requests.


  /// Static instance for singleton access.
  static final AuthManager instance = AuthManager._private();

  /// The current JWT token
  String? _jwt;
  User? currentUser;

  /// A stream that emits events whenever the user changes (e.g., login/logout).
  Stream<dynamic> get userChange => Stream.value(currentUser);

  /// A notifier to signal when the session has been invalidated, allowing the UI to react accordingly.
  final ValueNotifier<bool> sessionInvalidated = ValueNotifier(false);

  /// Get the current JWT token
  String? getJwt() {
    return _jwt;
  }

  /// Load the JWT from shared preferences.
  /// This should be called at app startup to restore the session if possible.
  Future<String?> loadJwt() async {
    final localStorage = await SharedPreferences.getInstance();
    _jwt = localStorage.getString(SharedPreferencesKeys.jwtToken);
    return _jwt;
  }

  /// Set the JWT and persist it in shared preferences.
  /// If the token is null, it will be removed from storage.
  Future<void> setJwt(String token) async {
    final localStorage = await SharedPreferences.getInstance();
    _jwt = token;
    await localStorage.setString(SharedPreferencesKeys.jwtToken, token);
  }

  /// Invalidate the current session by removing the JWT from storage and notifying listeners.
  Future<void> removeJwt() async {
    final localStorage = await SharedPreferences.getInstance();
    await localStorage.remove(SharedPreferencesKeys.jwtToken);
    _jwt = null;
    sessionInvalidated.value = true;
  }

  Future<String?> saveProfile(User profile) async {
    final localStorage = await SharedPreferences.getInstance();
    // TODO: implement saveProfile
    // await localStorage.setString('profile', profile.toJson());
    currentUser = profile;
    _jwt = localStorage.getString(SharedPreferencesKeys.jwtToken);
    return _jwt;
  }

  Future<User?> loadProfile() async {
    final localStorage = await SharedPreferences.getInstance();
    // TODO: implement loadProfile
    // final String? profileJson = localStorage.getString('profile');
    _jwt = localStorage.getString(SharedPreferencesKeys.jwtToken);
    return null;
  }

  Stream<dynamic> userChanges() {
    return userChange;
  }
}
