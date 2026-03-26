import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Champ de formulaire pour saisir un montant.
class AmountField extends StatelessWidget {
  const AmountField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      inputFormatters: const [AmountInputFormatter()],
      decoration: const InputDecoration(
        labelText: 'Montant',
        hintText: 'Ex: 42.50',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        final trimmedValue = value?.trim() ?? '';
        if (trimmedValue.isEmpty) {
          return 'Le montant est obligatoire';
        }

        final parsedAmount = parseAmountForField(trimmedValue);
        if (parsedAmount == null) {
          return 'Montant invalide';
        }

        if (parsedAmount <= 0) {
          return 'Le montant doit etre superieur a 0';
        }

        return null;
      },
    );
  }
}

/// InputFormatter pour le champ de montant, permettant uniquement les nombres avec jusqu'à 2 décimales.
class AmountInputFormatter extends TextInputFormatter {
  const AmountInputFormatter();

  static final _validPattern = RegExp(r'^\d*([\.,]\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty || _validPattern.hasMatch(newValue.text)) {
      return newValue;
    }

    return oldValue;
  }
}

/// Tente de parser une chaîne de caractères en montant (double), en gérant les virgules et les points.
double? parseAmountForField(String rawAmount) {
  final normalized = rawAmount.trim().replaceAll(',', '.');
  return double.tryParse(normalized);
}
