import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/auth_manager.dart';
import '../navigation/app_routes.dart';
import '../pages/code_entry_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';

class RootRouter extends StatefulWidget {
  const RootRouter({super.key});
  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter> {
  late final VoidCallback _authListener;
  Future<Map<String, dynamic>> _loadLocal() async {
    final sp = await SharedPreferences.getInstance();
    final jwt = sp.getString('jwt');
    final email = sp.getString('email');
    final name = sp.getString('name');
    // If we already have a jwt return quickly. Otherwise, if we have a
    // stored email+name try to register (signup) to obtain a fresh jwt.
    if ((jwt == null || jwt.isEmpty) && email != null && email.isNotEmpty && name != null && name.isNotEmpty) {
      try {
        final resp = await ApiService.registerUser(email, name);
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          final j = jsonDecode(resp.body);
          final newJwt = j['jwt'];
          if (newJwt != null) {
            await sp.setString('jwt', newJwt);
            return {'jwt': newJwt, 'email': email, 'name': name};
          }
        }
      } catch (e) {
        // ignore and fallthrough to return existing data
      }
    }
    return {'jwt': jwt, 'email': email, 'name': name};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(future: _loadLocal(), builder: (context, snap) {
      if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      final data = snap.data!;
      if (data['jwt'] != null && data['jwt'].toString().isNotEmpty) return const HomePage();
      if ((data['email'] ?? '').toString().isNotEmpty && (data['name'] ?? '').toString().isNotEmpty) {
        // We have a stored email+name: assume user previously signed up.
        // Try to re-register / refresh session by calling registerUser which
        // is expected to return a JWT. If that fails, fall back to code flow.
        ApiService.registerUser(data['email'], data['name']).then((resp) async {
          if (resp.statusCode >= 200 && resp.statusCode < 300) {
            try {
              final j = jsonDecode(resp.body);
              final jwt = j['jwt'];
              final sp = await SharedPreferences.getInstance();
              if (jwt != null) await sp.setString('jwt', jwt);
            } catch (e) {}
          }
        });
        return CodeEntryPage(email: data['email'], name: data['name']);
      }
      return const LoginPage();
    });
  }

  @override
  void initState() {
    super.initState();
    _authListener = () {
      if (AuthManager.instance.sessionInvalidated.value) {
        // ensure we remove any JWT stored locally and navigate to login
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final sp = await SharedPreferences.getInstance();
          await sp.remove('jwt');
          if (!mounted) return;
          // show session expired message then redirect
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session expirée')));
          await Future.delayed(const Duration(milliseconds: 400));
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
          // reset the flag so future logins can proceed
          AuthManager.instance.sessionInvalidated.value = false;
        });
      }
    };
    AuthManager.instance.sessionInvalidated.addListener(_authListener);
  }

  @override
  void dispose() {
    AuthManager.instance.sessionInvalidated.removeListener(_authListener);
    super.dispose();
  }
}
