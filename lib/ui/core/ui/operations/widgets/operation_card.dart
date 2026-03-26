import 'package:econoris_app/domain/models/operations/operation.dart';
import 'package:econoris_app/ui/core/themes/theme.dart';
import 'package:econoris_app/ui/core/ui/utils/format_amount.dart';
import 'package:econoris_app/ui/core/ui/utils/format_date.dart';
import 'package:econoris_app/ui/operations/view_models/operation_action.dart';
import 'package:flutter/material.dart';

/// Écran d'accueil de l'application.
class OperationCard extends StatelessWidget {
  const OperationCard({
    super.key,
    required this.operation,
    required this.operationAction,
  });

  final Operation operation;
  final OperationAction operationAction;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final String operationDate =
        formatDate(operation.levyDate, customFormat: 'dd MMMM yyyy') ?? '';

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: InkWell(
          onTap: () => operationAction.showDetails(operation),
          onLongPress: () => operationAction.onDeleteOperation(operation.id, 0),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  operation.subscriptionId == null
                      ? Icons.receipt_long_outlined
                      : (operation.levyDate.isAfter(DateTime.now())
                            ? Icons.event_repeat
                            : Icons.currency_exchange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        operation.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              operationDate,
                              style: TextStyle(
                                color: operation.isValidate
                                    ? AppTheme.successColor
                                    : AppTheme.infoColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Icon(
                            operation.isValidate
                                ? Icons.check_circle_outline
                                : Icons.hourglass_empty_outlined,
                            size: 16,
                            color: operation.isValidate
                                ? AppTheme.successColor
                                : AppTheme.infoColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatAmount(operation.amount),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: operation.amount >= 0
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
