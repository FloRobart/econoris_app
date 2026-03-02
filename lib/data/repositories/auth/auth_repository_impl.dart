import 'package:econoris_app/data/models/auth/user/user_dto.dart';
import 'package:econoris_app/data/models/auth/user/user_dto_mapper.dart';
import 'package:econoris_app/data/repositories/auth/auth_repository.dart';
import 'package:econoris_app/data/repositories/auth/auth_repository_local.dart';
import 'package:econoris_app/data/repositories/auth/auth_repository_remote.dart';
import 'package:econoris_app/domain/models/auth/user/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRepositoryRemote remote;
  final AuthRepositoryLocal local;

  AuthRepositoryImpl({required this.remote, required this.local});

  @override
  Future<void> requestLoginCode(String email) async {
    try {
      /* Save email in local storage */
      await local.saveEmail(email);

      /* Call API to request login code */
      final String token = await remote.requestLoginCode(email);

      /* Save the login token in local storage */
      await local.saveLoginToken(token);
    } catch (error) {
      throw Exception('Failed to request login code');
    }
  }

  @override
  Future<String?> getEmail() async {
    try {
      return await local.getEmail();
    } catch (_) {
      throw Exception('Failed to get email 1');
    }
  }

  @override
  Future<void> confirmLoginCode(String secret) async {
    try {
      final String email = await local.getEmail() ?? '';
      final String token = await local.getLoginToken() ?? '';
      final String jwt = await remote.confirmLoginCode(email, token, secret);
      await local.saveJwt(jwt);
    } catch (_) {
      throw Exception('Failed to confirm login code');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final String? jwt = await local.getJwt();
      return jwt != null;
    } catch (_) {
      return false;
    }
  }














  

  @override
  Future<void> logoutAll() async {
    try {
      await remote.logout();
      await local.logout();
    } catch (_) {
      throw Exception('Failed to logout from all devices');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await local.logout();
    } catch (_) {
      throw Exception('Failed to logout');
    }
  }

  @override
  Future<User> registerUser(String email, String pseudo) async {
    try {
      await remote.registerUser(email, pseudo);
      final profileDto = await remote.getProfile();
      final profile = profileDto.toDomain();
      await local.registerUser(profile);
      return profile;
    } catch (_) {
      throw Exception('Failed to register user');
    }
  }

  @override
  Future<User> getProfile() async {
    try {
      final UserDto dto = await remote.getProfile();
      final User user = dto.toDomain();
      await local.registerUser(user);

      return user;
    } catch (_) {
      final User user =
          await local.getProfile() ??
          (throw Exception('Failed to get profile'));
      return user;
    }
  }

  @override
  Future<User> updateProfile(String pseudo) async {
    try {
      final String email = await local.getEmail() ?? '';
      final String newJwt = await remote.updateProfile(email, pseudo);
      await local.saveJwt(newJwt);

      final profileDto = await remote.getProfile();
      final profile = profileDto.toDomain();
      await local.registerUser(profile);

      return profile;
    } catch (_) {
      throw Exception('Failed to update profile');
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      await remote.deleteUser();
      await local.deleteUser();
    } catch (_) {
      throw Exception('Failed to delete user');
    }
  }
}
