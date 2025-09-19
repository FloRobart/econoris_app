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
    return {'jwt': jwt, 'email': email, 'name': name};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(future: _loadLocal(), builder: (context, snap) {
      if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      final data = snap.data!;
      if (data['jwt'] != null && data['jwt'].toString().isNotEmpty) return const HomePage();
      if ((data['email'] ?? '').toString().isNotEmpty && (data['name'] ?? '').toString().isNotEmpty) {
        // request login code then go to code entry
        ApiService.requestLoginCode(data['email'], data['name']);
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
