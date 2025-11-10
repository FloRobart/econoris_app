import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyTotalsBanner extends StatelessWidget {
  final String revenueLabel;
  final String expenseLabel;
  final double revenueAmount;
  final double expenseAmount;
  final String locale;
  final String currencySymbol;

  const MonthlyTotalsBanner({
    super.key,
    required this.revenueLabel,
    required this.expenseLabel,
    required this.revenueAmount,
    required this.expenseAmount,
    this.locale = 'fr_FR',
    this.currencySymbol = '€',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: locale, symbol: currencySymbol);
    final bool expenseHigher = expenseAmount > revenueAmount;
    // use the bodyMedium text color for icons so they match the label color
    final Color labelColor = theme.textTheme.bodyMedium?.color ?? theme.iconTheme.color!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.arrow_upward, size: 18, color: labelColor),
                  const SizedBox(width: 8),
                  Text(revenueLabel, style: theme.textTheme.bodyMedium),
                ]),
                Text(
                  currency.format(revenueAmount),
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.arrow_downward, size: 18, color: expenseHigher ? Colors.red : labelColor),
                  const SizedBox(width: 8),
                  Text(expenseLabel, style: theme.textTheme.bodyMedium),
                ]),
                Text(
                  currency.format(expenseAmount),
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: expenseHigher ? Colors.red : null),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
