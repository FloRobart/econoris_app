import 'package:econoris_app/domain/models/subscriptions/subscription.dart';
import 'package:econoris_app/ui/core/ui/utils/format_amount.dart';
import 'package:econoris_app/ui/core/ui/utils/format_date.dart';
import 'package:flutter/material.dart';

class SubscriptionDetails extends StatelessWidget {
  const SubscriptionDetails({
    super.key,
    required this.subscription,
    required this.onDeleteSubscription,
  });

  final Subscription subscription;
  final Future<void> Function(int id) onDeleteSubscription;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String subscriptionDate =
        formatDate(subscription.lastGeneratedAt, customFormat: 'dd MMMM yyyy') ?? '-';

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
            Text('Détails de l\'abonnement', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            detailRow(label: 'Libellé', value: subscription.label),
            detailRow(label: 'Date', value: subscriptionDate),
            detailRow(
              label: 'Montant',
              value: formatAmount(subscription.amount),
            ),
            detailRow(label: 'Catégorie', value: subscription.category),
            detailRow(label: 'Source', value: subscription.source ?? '-'),
            detailRow(
              label: 'Destination',
              value: subscription.destination ?? '-',
            ),
            detailRow(
              label: 'Statut',
              value: subscription.active ? 'Actif' : 'Inactif',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () => onDeleteSubscription(subscription.id),
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
