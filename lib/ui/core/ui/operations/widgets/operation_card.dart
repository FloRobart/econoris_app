import 'package:econoris_app/domain/models/operations/operation.dart';
import 'package:econoris_app/ui/core/ui/utils/format_date.dart';
import 'package:flutter/material.dart';

/// Écran d'accueil de l'application.
class OperationCard extends StatelessWidget {
  const OperationCard({super.key, required this.operation});

  final Operation operation;

  @override
  Widget build(BuildContext context) {
    final String operationDate =
        formatDate(operation.levyDate, customFormat: 'dd MMMM yyyy') ?? '';
    final String amountText = '${operation.amount.toStringAsFixed(2)} €';

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.receipt_long_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      operation.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      operationDate,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: operation.isValidate
                            ? Colors.green
                            : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                amountText,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: operation.amount >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
