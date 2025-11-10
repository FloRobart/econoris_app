import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
import '../services/auth_manager.dart';
import '../navigation/app_routes.dart';
// code_entry_page import removed: root router no longer auto-redirects to code entry
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
    // If we already have a jwt return quickly. We no longer store the
    // user's name locally, so we only return jwt and email.
    return {'jwt': jwt, 'email': email};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(future: _loadLocal(), builder: (context, snap) {
      if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      final data = snap.data!;
      if (data['jwt'] != null && data['jwt'].toString().isNotEmpty) return const HomePage();
      // Default when not authenticated: show the login page (no name required)
      return const LoginPage.login();
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
          if (!mounted) return;
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
