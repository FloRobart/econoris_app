import 'package:econoris_app/providers/ui/auth/login_body_viewmodel_provider.dart';
import 'package:econoris_app/routing/routes.dart';
import 'package:econoris_app/ui/auth/widgets/auth_base.dart';
import 'package:econoris_app/ui/auth/widgets/login/login_body.dart';
import 'package:econoris_app/ui/core/ui/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Écran d'authentification affichant le formulaire de connexion et d'inscription.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailAsync = ref.watch(authInitialEmailProvider);

    /* Écoute des changements d'état de l'authentification pour naviguer ou afficher des erreurs */
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.hasValue) {
        context.go(AppRoutes.codeEntry);
      }

      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

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
