import 'package:econoris_app/ui/core/ui/widgets/base_app.dart';
import 'package:flutter/material.dart';

/// Écran de connexion pour la demande d'authentification de l'utilisateur.
class CodeEntryScreen extends StatelessWidget {
  const CodeEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      body: const Center(child: Text('Code Entry Screen')),
    );
  }
}
