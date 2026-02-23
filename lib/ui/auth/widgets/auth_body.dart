import 'package:econoris_app/providers/ui/auth/auth_screen_viewmodel_provider.dart';
import 'package:econoris_app/routing/routes.dart';
import 'package:econoris_app/ui/auth/widgets/login_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AuthBody extends ConsumerStatefulWidget {
  const AuthBody({super.key, required this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<AuthBody> createState() => _AuthBodyState();
}

class _AuthBodyState extends ConsumerState<AuthBody> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController =
        TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(authScreenViewModelProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LoginHeader(),
        const SizedBox(height: 28),

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

        ElevatedButton(
          onPressed: () async {
            final loginRequestSuccess = await viewModel.loginRequest(_emailController.text);
            if (!loginRequestSuccess) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Échec de la connexion. Veuillez réessayer.')),
              );
            }

            if (!mounted) return;
            context.go(AppRoutes.codeEntry);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text('Se connecter'),
        ),

        const SizedBox(height: 12),

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


