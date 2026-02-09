import 'package:econoris_app/data/services/api/auth_api_client.dart';
import 'package:econoris_app/data/services/auth_manager.dart';
import 'package:econoris_app/domain/models/auth/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryLocal {
  final AuthApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AuthRepositoryLocal(this.apiClient, this.sharedPreferences);

  /// Save the email in local storage for later use in the login process.
  Future<void> saveEmail(String email) async {
    await sharedPreferences.setString('email', email);
  }

  /// Get the email from local storage, if it exists.
  /// Returns the email if it exists, or null if it doesn't.
  Future<String?> getEmail() async {
    return sharedPreferences.getString('email');
  }

  /// Save the secret in local storage for later use in the login process.
  Future<void> saveLoginToken(String secret) async {
    await sharedPreferences.setString('login_token', secret);
  }

  /// Get the secret from local storage, if it exists.
  /// Returns the secret if it exists, or null if it doesn't.
  Future<String?> getLoginToken() async {
    return sharedPreferences.getString('login_token');
  }

  /// Save the JWT token in local storage for later use in authenticated requests.
  Future<void> saveJwt(String jwt) async {
    await AuthManager.instance.setJwt(jwt);
  }

  /// Get the JWT token from local storage, if it exists.
  /// Returns the JWT token if it exists, or null if it doesn't.
  Future<String?> getJwt() async {
    return AuthManager.instance.jwt;
  }

  /// Logs out the user by remove local JWT token.
  /// This is a local operation, so it doesn't need to return anything.
  Future<void> logout() async {
    await AuthManager.instance.removeJwt();
  }

  /// Registers a new user with the provided email and pseudo.
  /// Returns the JWT token if the registration is successful.
  Future<String?> registerUser(Profile profile) async {
    return await AuthManager.instance.saveProfile(profile);
  }

  /// Retrieves the user's profile information.
  /// Returns a [Profile] containing the user's profile data.
  Future<Profile?> getProfile() async {
    return await AuthManager.instance.loadProfile();
    // final String? profileJson = await sharedPreferencesService.getString('profile');
    // if (profileJson == null) {
    //   throw Exception('No profile found in local storage');
    // }
    // return Profile.fromJson(profileJson);
  }

  /// Updates the user's profile with the provided pseudo.
  /// Returns the new JWT token if the update is successful.
  Future<String?> updateProfile(String pseudo) async {
    // TODO: implement updateProfile
    throw UnimplementedError();
  }

  /// Deletes the user's account.
  Future<void> deleteUser() async {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }
}
