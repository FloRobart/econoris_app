import 'package:econoris_app/providers/ui/auth/login_body_viewmodel_provider.dart';
import 'package:econoris_app/routing/routes.dart';
import 'package:econoris_app/ui/auth/widgets/login/login_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Widget affichant le formulaire de connexion et d'inscription.
class LoginBody extends ConsumerStatefulWidget {
  const LoginBody({super.key, required this.initialEmail, this.errorMessage});

  final String? initialEmail;
  final String? errorMessage;

  @override
  ConsumerState<LoginBody> createState() => _AuthBodyState();
}

/// État du widget [LoginBody] gérant la logique de connexion et d'inscription.
class _AuthBodyState extends ConsumerState<LoginBody> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController =
        TextEditingController(text: widget.initialEmail ?? '');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.errorMessage ?? 'Erreur inconnue')),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(loginBodyViewModelProvider);

    /* Affichage d'une erreur */
    void displayLoginError(String errorMessage) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }

    /* Resultat de la tentative de connexion */
    void handleLoginResult(bool loginRequestSuccess) {
      if (!loginRequestSuccess) {
        displayLoginError('Échec de la connexion. Veuillez réessayer.');
      }

      if (!mounted) return;
      context.go(AppRoutes.codeEntry);
    }


    /* Widget */
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LoginHeader(),
        const SizedBox(height: 28),

        /* Champ de saisie de l'email */
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Entrez votre adresse email',
            prefixIcon: Icon(Icons.mail),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 16),

        /* Bouton de connexion */
        ElevatedButton(
          onPressed: () async {
            final loginRequestSuccess = await viewModel.loginRequest(_emailController.text);
            handleLoginResult(loginRequestSuccess);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text('Se connecter'),
        ),

        const SizedBox(height: 12),

        /* Bouton de création de compte */
        OutlinedButton.icon(
          onPressed: () {
            viewModel.register(_emailController.text, 'PseudoTemp');
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Créer un compte'),
        ),
      ],
    );
  }
}


