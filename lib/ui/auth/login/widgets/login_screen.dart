import 'package:econoris_app/ui/auth/widgets/auth_base.dart';
import 'package:econoris_app/ui/auth/login/widgets/login_body.dart';
import 'package:econoris_app/ui/auth/login/widgets/login_header.dart';
import 'package:flutter/material.dart';

/// Écran d'authentification affichant le formulaire de connexion et d'inscription.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBase(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [LoginHeader(), SizedBox(height: 28), LoginBody()],
      ),
    );
  }
}
