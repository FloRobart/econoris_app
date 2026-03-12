import 'dart:convert';

import 'package:econoris_app/config/shared_preferences_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Definit les différents états d'authentification possibles pour l'application.
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Fournit une instance de [AuthManager] pour gérer l'état d'authentification global de l'application.
final authNotifierProvider = NotifierProvider<AuthManager, AuthStatus>(
  AuthManager.new,
);

/// Ce fichier contient le [AuthManager] qui gère l'état d'authentification global de l'application.
class AuthManager extends Notifier<AuthStatus> {
  String? _jwt;
  String? _email;

  @override
  AuthStatus build() {
    _init();
    return AuthStatus.unknown;
  }

  /// Initialise le notifier en chargeant le JWT depuis le stockage local et en définissant l'état d'authentification.
  Future<void> _init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _jwt = prefs.getString(SharedPreferencesKeys.jwtToken);

    if (_jwt != null && expireIn > 0) {
      _email = _getEmailFromJwt();
      state = AuthStatus.authenticated;
    } else {
      state = AuthStatus.unauthenticated;
    }
  }

  /// Récupère le JWT actuellement stocké.
  String? get getJwt => _jwt;

  /// Récupère l'email de l'utilisateur actuellement connecté.
  String? get getEmail => _email;

  /// Indique si l'utilisateur est actuellement authentifié.
  bool get isAuthenticated {
    return state == AuthStatus.authenticated && _jwt != null && expireIn > 0;
  }

  /// Calcule le temps restant avant l'expiration du JWT en secondes.
  int get expireIn {
    if (_jwt == null) return 0;

    final parts = _jwt!.split('.');
    if (parts.length != 3) return 0;

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final Map<String, dynamic> payloadMap = jsonDecode(decoded);

    if (!payloadMap.containsKey('exp')) return 0;

    final exp = payloadMap['exp'];
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return exp - currentTime;
  }

  /// Remove the JWT from local storage and update the authentication state to unauthenticated.
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(SharedPreferencesKeys.jwtToken);
    _jwt = null;
    _email = null;
    state = AuthStatus.unauthenticated;
  }

  /// Set the authentication state to authenticated and save the JWT in local storage.
  Future<void> setAuthenticated(String jwt) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedPreferencesKeys.jwtToken, jwt);
    _jwt = jwt;
    _email = _getEmailFromJwt();
    state = AuthStatus.authenticated;
  }

  /// Récupère l'email de l'utilisateur à partir du JWT.
  String? _getEmailFromJwt() {
    if (_jwt == null) return null;

    final parts = _jwt!.split('.');
    if (parts.length != 3) return null;

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final Map<String, dynamic> payloadMap = jsonDecode(decoded);

    if (payloadMap.containsKey('email')) {
      return payloadMap['email'];
    }

    return null;
  }
}
