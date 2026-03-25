import 'package:econoris_app/domain/models/operations/operation.dart';
import 'package:econoris_app/ui/core/ui/utils/format_date.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OperationDetails extends StatelessWidget {
  const OperationDetails({
    super.key,
    required this.operation,
    required this.deleteOperation,
  });

  final Operation operation;
  final Future<void> Function(int id) deleteOperation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String amount = '${operation.amount.toStringAsFixed(2)} €';
    final String operationDate =
        formatDate(operation.levyDate, customFormat: 'dd MMMM yyyy') ?? '-';

    Widget detailRow({required String label, required String value}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Détails de l\'opération', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            detailRow(label: 'Libellé', value: operation.label),
            detailRow(label: 'Date', value: operationDate),
            detailRow(
              label: 'Montant',
              value: '${operation.amount > 0 ? '+' : ''}$amount',
            ),
            detailRow(label: 'Catégorie', value: operation.category),
            detailRow(label: 'Source', value: operation.source ?? '-'),
            detailRow(
              label: 'Destination',
              value: operation.destination ?? '-',
            ),
            detailRow(
              label: 'Statut',
              value: operation.isValidate ? 'Validée' : 'En attente',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () async {
                  final bool? shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) {
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

                  if (context.mounted) {
                    GoRouter.of(context).pop();
                  }

                  await deleteOperation(operation.id);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opération supprimée.')),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Supprimer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
