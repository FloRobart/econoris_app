import 'package:econoris_app/ui/auth/login/view_models/login_body_viewmodel.dart';
import 'package:econoris_app/ui/auth/login/widgets/login_form.dart';
import 'package:econoris_app/ui/core/ui/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget affichant le formulaire de connexion et d'inscription.
class LoginBody extends ConsumerWidget {
  const LoginBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailAsync = ref.watch(authInitialEmailProvider);

    return emailAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => const LoginForm(
        initialEmail: '',
        errorMessage: 'Erreur de chargement de l\'email',
      ),
      data: (email) => LoginForm(initialEmail: email),
    );
  }
}
