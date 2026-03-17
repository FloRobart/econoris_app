import 'package:econoris_app/domain/models/operations/operation.dart';
import 'package:econoris_app/ui/core/ui/operations/widgets/operation_card.dart';
import 'package:flutter/material.dart';

/// Écran d'accueil de l'application.
class OperationsTable extends StatelessWidget {
  const OperationsTable({super.key, required this.operations});

  final List<Operation> operations;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: operations.length * 15,
      itemBuilder: (context, index) =>
          OperationCard(operation: operations[index % 3]),
    );
  }
}
