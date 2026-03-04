import 'package:econoris_app/ui/auth/login/view_models/login_body_viewmodel.dart';
import 'package:econoris_app/ui/auth/widgets/auth_base.dart';
import 'package:econoris_app/ui/auth/login/widgets/login_body.dart';
import 'package:econoris_app/ui/core/ui/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran d'authentification affichant le formulaire de connexion et d'inscription.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailAsync = ref.watch(authInitialEmailProvider);

    return AuthBase(
      body: emailAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => const LoginBody(
          initialEmail: '',
          errorMessage: 'Erreur de chargement de l\'email',
        ),
        data: (email) => LoginBody(initialEmail: email),
      ),
    );
  }
}
