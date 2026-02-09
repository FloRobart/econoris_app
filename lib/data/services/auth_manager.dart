import 'package:econoris_app/data/models/auth/profile_dto.dart';
import 'package:econoris_app/domain/models/auth/profile.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton class to manage authentication state, including JWT storage and session invalidation.
class AuthManager {
  /// Private constructor for singleton pattern.
  AuthManager._private();

  /// Static instance for singleton access.
  static final AuthManager instance = AuthManager._private();

  /// The current JWT token
  String? _jwt;

  /// A notifier to signal when the session has been invalidated, allowing the UI to react accordingly.
  final ValueNotifier<bool> sessionInvalidated = ValueNotifier(false);

  /// Getter for the current JWT.
  String? get jwt => _jwt;

  /// Load the JWT from shared preferences.
  /// This should be called at app startup to restore the session if possible.
  Future<String?> loadJwt() async {
    final localStorage = await SharedPreferences.getInstance();
    _jwt = localStorage.getString('jwt');
    return _jwt;
  }

  /// Set the JWT and persist it in shared preferences.
  /// If the token is null, it will be removed from storage.
  Future<void> setJwt(String token) async {
    final localStorage = await SharedPreferences.getInstance();
    _jwt = token;
    await localStorage.setString('jwt', token);
  }

  /// Invalidate the current session by removing the JWT from storage and notifying listeners.
  Future<void> removeJwt() async {
    final localStorage = await SharedPreferences.getInstance();
    await localStorage.remove('jwt');
    _jwt = null;
    sessionInvalidated.value = true;
  }

  Future<String?> saveProfile(Profile profile) async {
    final localStorage = await SharedPreferences.getInstance();
    // TODO: implement saveProfile
    // await localStorage.setString('profile', profile.toJson());
    _jwt = localStorage.getString('jwt');
    return _jwt;
  }

  Future<Profile?> loadProfile() async {
    final localStorage = await SharedPreferences.getInstance();
    // TODO: implement loadProfile
    // final String? profileJson = localStorage.getString('profile');
    _jwt = localStorage.getString('jwt');
    return null;
  }
}