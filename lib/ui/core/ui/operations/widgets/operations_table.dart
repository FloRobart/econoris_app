import 'package:econoris_app/domain/models/operations/operation.dart';
import 'package:econoris_app/ui/core/ui/operations/widgets/operation_card.dart';
import 'package:flutter/material.dart';

/// Écran d'accueil de l'application.
class OperationsTable extends StatelessWidget {
  const OperationsTable({super.key, required this.operations});

  final List<Operation> operations;

  @override
  Widget build(BuildContext context) {
    if (operations.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Operation> displayedOperations = List<Operation>.generate(
      operations.length * 15,
      (index) => operations[index % operations.length],
    );

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
              if (index != 0) const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
            ],
            OperationCard(operation: operation),
          ],
        );
      },
    );
  }
}
