import 'package:econoris_app/domain/models/operations/operation.dart';
import 'package:econoris_app/ui/core/ui/operations/widgets/operation_card.dart';
import 'package:econoris_app/ui/core/ui/utils/format_date.dart';
import 'package:econoris_app/ui/operations/view_models/operation_action.dart';
import 'package:flutter/material.dart';

/// Écran d'accueil de l'application.
class OperationsList extends StatelessWidget {
  const OperationsList({
    super.key,
    required this.operations,
    required this.operationAction
  });

  final List<Operation> operations;
  final OperationAction operationAction;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    if (operations.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Operation> displayedOperations = List<Operation>.generate(
      operations.length,
      (index) => operations[index],
    );

    final Map<DateTime, int> operationCountByDate = <DateTime, int>{};
    for (final Operation operation in displayedOperations) {
      final DateTime dateKey = DateUtils.dateOnly(operation.levyDate);
      operationCountByDate[dateKey] = (operationCountByDate[dateKey] ?? 0) + 1;
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayedOperations.length,
      itemBuilder: (context, index) {
        final Operation operation = displayedOperations[index];
        final bool showDateSeparator =
            index == 0 ||
            !DateUtils.isSameDay(
              displayedOperations[index - 1].levyDate,
              operation.levyDate,
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateSeparator) ...[
              if (index != 0) const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    DateUtils.isSameDay(operation.levyDate, DateTime.now())
                        ? ' Aujourd\'hui'
                        : formatDate(
                                operation.levyDate,
                                customFormat: ' EEEE dd MMMM yyyy',
                              ) ??
                              ' Date Inconnu',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Text(
                    '${operationCountByDate[DateUtils.dateOnly(operation.levyDate)] ?? 0} ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 1),
              const SizedBox(height: 4),
            ],
            OperationCard(
              operation: operation,
              operationAction: operationAction,
            ),
          ],
        );
      },
    );
  }
}
