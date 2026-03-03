import 'package:econoris_app/ui/auth/widgets/auth_base.dart';
import 'package:econoris_app/ui/auth/code_entry/widgets/code_entry_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran de connexion pour la demande d'authentification de l'utilisateur.
class CodeEntryScreen extends ConsumerWidget {
  const CodeEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthBase(
      body: CodeEntryBody()
    );
  }
}
