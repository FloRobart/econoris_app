import 'package:flutter/material.dart';

/// Champ de formulaire pour saisir un nom.
class LabelField extends StatelessWidget {
  const LabelField({super.key, required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      maxLength: 200,
      decoration: InputDecoration(
        labelText: 'Nom',
        hintText: hintText,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final trimmedValue = value?.trim() ?? '';
        if (trimmedValue.isEmpty) {
          return 'Le nom est obligatoire';
        }

        return null;
      },
    );
  }
}