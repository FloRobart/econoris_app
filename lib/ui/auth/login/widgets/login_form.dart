import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:econoris_app/ui/auth/login/view_models/login_viewmodel.dart';

class LoginForm extends ConsumerWidget {
  final String? email;
  final bool requireName;

  const LoginForm({super.key, required this.email, required this.requireName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController(text: email ?? '');
    final nameController = TextEditingController();
    final isWide = MediaQuery.of(context).size.width > 600;

    return Center(
      child: Container(
        width: isWide ? 500 : double.infinity,
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),

                if (requireName) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Prénom'),
                  ),
                ],

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      requireName
                          ? 'Déjà un compte ?'
                          : "Pas encore de compte ?",
                    ),
                    TextButton(
                      onPressed: () => ref
                          .read(loginViewModelProvider.notifier)
                          .toggleMode(),
                      child: Text(requireName ? 'Se connecter' : "S'inscrire"),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => ref
                        .read(loginViewModelProvider.notifier)
                        .requestLoginCode(emailController.text),
                    child: Text(requireName ? "S'inscrire" : 'Se connecter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
