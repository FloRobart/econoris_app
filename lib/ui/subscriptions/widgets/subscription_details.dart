import 'package:econoris_app/domain/models/subscriptions/subscription.dart';
import 'package:econoris_app/ui/core/themes/theme.dart';
import 'package:econoris_app/ui/core/ui/utils/format_amount.dart';
import 'package:econoris_app/ui/core/ui/utils/format_date.dart';
import 'package:econoris_app/ui/subscriptions/view_models/subscription_form_viewmodel.dart';
import 'package:flutter/material.dart';

class SubscriptionDetails extends StatelessWidget {
  const SubscriptionDetails({
    super.key,
    required this.subscription,
    required this.onDeleteSubscription,
    required this.onEditSubscription,
  });

  final Subscription subscription;
  final Future<void> Function(int id) onDeleteSubscription;
  final Future<void> Function(Subscription subscription) onEditSubscription;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String subscriptionDate =
        formatDate(
          subscription.lastGeneratedAt,
          customFormat: 'dd MMMM yyyy',
        ) ??
        '-';

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
            Row(
              children: [
                Icon(Icons.event_repeat, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Détails de l\'abonnement',
                  style: theme.textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => onEditSubscription(subscription),
                  icon: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Modifier',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            detailRow(
              label: 'Récurrence',
              value: recurrenceFromInterval(
                intervalValue: subscription.intervalValue,
                intervalUnit: subscription.intervalUnit,
              ),
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
            const SizedBox(height: 8),
            Text(
              subscription.active
                  ? 'Cet abonnement est actif.'
                  : 'Cet abonnement est inactif.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: subscription.active
                    ? AppTheme.successColor
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
