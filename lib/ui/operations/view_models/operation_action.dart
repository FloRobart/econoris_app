import 'package:econoris_app/domain/models/operations/operation.dart';
import 'package:econoris_app/ui/operations/widgets/operation_details.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OperationAction {
  OperationAction(this.deleteOperation, this.context);

  final Future<void> Function(int id) deleteOperation;
  final BuildContext context;

  /// Affiche les détails d'une opération dans une bottom sheet.
  Future<void> showDetails(Operation operation) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => OperationDetails(
        operation: operation,
        deleteOperation: onDeleteOperation,
      ),
    );
  }

  /// Affiche une boîte de dialogue de confirmation avant de supprimer une opération.
  Future<void> onDeleteOperation(int id) async {
    try {
      final bool? shouldDelete = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          ThemeData theme = Theme.of(dialogContext);

          return AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: const Text(
              'Cette opération sera supprimée définitivement.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  GoRouter.of(dialogContext).pop(false);
                },
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () {
                  GoRouter.of(dialogContext).pop(true);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                child: const Text('Supprimer'),
              ),
            ],
          );
        },
      );

      if (shouldDelete != true) {
        return;
      }

      await deleteOperation(id);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Opération supprimée.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Une erreur est survenue lors de la suppression de l\'opération.',
            ),
          ),
        );
      }
    }
  }
}
