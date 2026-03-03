import 'package:econoris_app/data/repositories/auth/auth_repository.dart';
import 'package:econoris_app/data/repositories/auth/auth_repository_local.dart';
import 'package:econoris_app/data/repositories/auth/auth_repository_remote.dart';
import 'package:econoris_app/data/services/auth/global_auth_notifier.dart';
import 'package:flutter/material.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remote,
    required this.local,
    required this.globalAuthNotifier,
  });

  final AuthRepositoryRemote remote;
  final AuthRepositoryLocal local;
  final GlobalAuthNotifier globalAuthNotifier;

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
  Future<bool> confirmLoginCode(String secret) async {
    try {
      final String email = await local.getEmail() ?? '';
      final String token = await local.getLoginToken() ?? '';
      final String jwt = await remote.confirmLoginCode(email, token, secret);
      debugPrint('JWT : $jwt');
      await local.saveJwt(jwt);
      globalAuthNotifier.setAuthenticated();

      return true;
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
}
