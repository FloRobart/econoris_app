import 'package:econoris_app/config/shared_preferences_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryLocal {
  /// Save the email in local storage for later use in the login process.
  Future<void> saveEmail(String email) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(SharedPreferencesKeys.userEmail, email);
  }

  /// Get the email from local storage, if it exists.
  /// Returns the email if it exists, or null if it doesn't.
  Future<String?> getEmail() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(SharedPreferencesKeys.userEmail);
  }

  /// Save the secret in local storage for later use in the login process.
  Future<void> saveLoginToken(String secret) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(SharedPreferencesKeys.loginToken, secret);
  }

  /// Get the secret from local storage, if it exists.
  /// Returns the secret if it exists, or null if it doesn't.
  Future<String?> getLoginToken() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(SharedPreferencesKeys.loginToken);
  }

  /// Save the JWT token in local storage for later use in authenticated requests.
  Future<void> saveJwt(String jwt) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(SharedPreferencesKeys.jwtToken, jwt);
  }

  /// get the JWT token in local storage for later use in authenticated requests.
  Future<String?> getJwt() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(SharedPreferencesKeys.jwtToken);
  }

  /// Logs out the user by remove local JWT token.
  /// This is a local operation, so it doesn't need to return anything.
  Future<void> logout() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove(SharedPreferencesKeys.jwtToken);
  }
}
