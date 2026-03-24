
import 'package:econoris_app/routing/routes.dart';
import 'package:econoris_app/ui/auth/login/view_models/login_body_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// État du formulaire de connexion et d'inscription.
class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key, required this.initialEmail, this.errorMessage});

  final String? initialEmail;
  final String? errorMessage;

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  late final TextEditingController _emailController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');

    final errorMessage = widget.errorMessage;
    if (errorMessage == null || errorMessage.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    });
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }

    /* Resultat de la tentative de connexion */
    void handleLoginResult(bool loginRequestSuccess) {
      if (!loginRequestSuccess) {
        displayLoginError('Échec de la connexion. Veuillez réessayer.');
      }

      if (!mounted) return;
      context.go(AppRoutes.codeEntry);
    }

    /// Envoie la requête de connexion et gère le résultat.
    Future<void> submitLoginRequest() async {
      if (_isSubmitting) {
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        final loginRequestSuccess = await viewModel.loginRequest(
          _emailController.text,
        );
        handleLoginResult(loginRequestSuccess);
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }

    /* Widget */
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        /* Champ de saisie de l'email */
        TextFormField(
          controller: _emailController,
          enabled: !_isSubmitting,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: _isSubmitting ? null : (_) => submitLoginRequest(),
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
          onPressed: _isSubmitting ? null : submitLoginRequest,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : const Text('Se connecter / S\'inscrire'),
        ),
      ],
    );
  }
}
