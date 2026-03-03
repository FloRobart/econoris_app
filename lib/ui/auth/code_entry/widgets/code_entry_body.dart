import 'package:econoris_app/ui/auth/code_entry/view_models/code_entry_body_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran de connexion pour la demande d'authentification de l'utilisateur.
class CodeEntryBody extends ConsumerWidget {
  const CodeEntryBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(codeEntryBodyViewModelProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Entrez le code de vérification envoyé à votre email'),
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) => viewModel.code = value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Code de vérification',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => viewModel.verifyCode(),
            child: const Text('Vérifier'),
          ),
        ],
      ),
    );
  }
}
