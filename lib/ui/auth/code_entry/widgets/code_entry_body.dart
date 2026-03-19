import 'package:econoris_app/ui/auth/code_entry/view_models/code_entry_body_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran de connexion pour la demande d'authentification de l'utilisateur.
class CodeEntryBody extends ConsumerStatefulWidget {
  const CodeEntryBody({super.key});

  @override
  ConsumerState<CodeEntryBody> createState() => _CodeEntryBodyState();
}

class _CodeEntryBodyState extends ConsumerState<CodeEntryBody> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.read(codeEntryBodyViewModelProvider);

    Future<void> submitVerification() async {
      if (_isSubmitting) {
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        final success = await viewModel.verifyCode();
        if (!success) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Code de vérification incorrect.')),
            );
          }
        }
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            enabled: !_isSubmitting,
            textInputAction: TextInputAction.done,
            onChanged: (value) => viewModel.code = value,
            onSubmitted: _isSubmitting ? null : (_) => submitVerification(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Code de vérification',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSubmitting ? null : submitVerification,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Text('Vérifier'),
          ),
        ],
      ),
    );
  }
}
