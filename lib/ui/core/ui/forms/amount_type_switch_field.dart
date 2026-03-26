import 'package:econoris_app/ui/core/themes/theme.dart';
import 'package:flutter/material.dart';

enum AmountType { expense, income }

/// Champ de formulaire pour sélectionner le type d'opération (dépense ou revenu).
class AmountTypeSwitchField extends StatelessWidget {
  const AmountTypeSwitchField({
    super.key,
    required this.isExpense,
    required this.onChanged,
  });

  final bool isExpense;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedType = isExpense
        ? AmountType.expense
        : AmountType.income;

    return Row(
      children: [
        Expanded(
          child: Text(
            isExpense ? 'Depense' : 'Revenu',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isExpense ? AppTheme.errorColor : AppTheme.successColor,
            ),
          ),
        ),
        SegmentedButton<AmountType>(
          segments: const [
            ButtonSegment<AmountType>(
              value: AmountType.expense,
              icon: Icon(Icons.arrow_downward_rounded),
              label: Text('Depense'),
            ),
            ButtonSegment<AmountType>(
              value: AmountType.income,
              icon: Icon(Icons.arrow_upward_rounded),
              label: Text('Revenu'),
            ),
          ],
          selected: {selectedType},
          style: SegmentedButton.styleFrom(
            selectedForegroundColor: isExpense
                ? AppTheme.errorColor
                : AppTheme.successColor,
          ),
          showSelectedIcon: false,
          onSelectionChanged: (selection) {
            if (selection.isEmpty) {
              return;
            }

            onChanged(selection.first == AmountType.expense);
          },
        ),
      ],
    );
  }
}
