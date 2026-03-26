import 'package:econoris_app/ui/auth/widgets/auth_base.dart';
import 'package:econoris_app/ui/auth/code_entry/widgets/code_entry_body.dart';
import 'package:flutter/material.dart';

/// Écran de validation du code de vérification envoyé à l'utilisateur par email.
class CodeEntryScreen extends StatelessWidget {
  const CodeEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBase(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'Entrez le code de vérification que vous avez reçu par email',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const CodeEntryBody(),
        ],
      ),
    );
  }
}
