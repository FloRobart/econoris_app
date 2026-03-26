import 'package:flutter/material.dart';

/// Bouton de soumission pour valider un formulaire.
class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      child: const Text('Valider'),
    );
  }
}
