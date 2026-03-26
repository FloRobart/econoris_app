import 'package:flutter/material.dart';

/// Champ de formulaire pour sélectionner une date.
class DateField extends StatelessWidget {
  const DateField({super.key, required this.selectedDate, required this.onTap});

  final DateTime selectedDate;
  final Future<DateTime?> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: selectedDate,
      validator: (value) {
        if (value == null) {
          return 'La date est obligatoire';
        }

        return null;
      },
      builder: (state) {
        final dateText = MaterialLocalizations.of(
          context,
        ).formatCompactDate(selectedDate);

        return InkWell(
          onTap: () async {
            final pickedDate = await onTap();
            if (pickedDate != null) {
              state.didChange(pickedDate);
            }
          },
          borderRadius: BorderRadius.circular(4),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Date',
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
              errorText: state.errorText,
            ),
            child: Text(dateText),
          ),
        );
      },
    );
  }
}
