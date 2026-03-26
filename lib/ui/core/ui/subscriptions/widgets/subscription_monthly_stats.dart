import 'package:econoris_app/ui/core/ui/subscriptions/view_models/subscription_stats_viewmodel.dart';
import 'package:econoris_app/ui/core/ui/utils/format_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget affichant des statistiques mensuelles sur les opérations.
class SubscriptionMonthlyStats extends StatelessWidget {
  const SubscriptionMonthlyStats({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.insights_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Statistiques des abonnements',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _StatsTilesSection(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Section affichant les différentes statistiques du mois sous forme de cartes.
class _StatsTilesSection extends ConsumerWidget {
  const _StatsTilesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncStats = ref.watch(subscriptionStatsProvider);

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Abonnements',
            value: asyncStats.when(
              data: (stats) => stats.subscriptionsCount.toString(),
              loading: () => '0',
              error: (error, stackTrace) => '0',
            ),
            subtitle: formatAmount(
              asyncStats.when(
                data: (stats) => stats.subscriptionsAmount,
                loading: () => 0,
                error: (error, stackTrace) => 0,
              ),
            ),
            icon: Icons.receipt_long_outlined,
            valueColor: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            label: 'Entrées',
            value: asyncStats.when(
              data: (stats) => stats.positiveSubscriptionsCount.toString(),
              loading: () => '0',
              error: (error, stackTrace) => '0',
            ),
            subtitle: formatAmount(
              asyncStats.when(
                data: (stats) => stats.positiveSubscriptionsAmount,
                loading: () => 0,
                error: (error, stackTrace) => 0,
              ),
            ),
            icon: Icons.trending_up,
            valueColor: Colors.green.shade700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            label: 'Sorties',
            value: asyncStats.when(
              data: (stats) => stats.negativeSubscriptionsCount.toString(),
              loading: () => '0',
              error: (error, stackTrace) => '0',
            ),
            subtitle: formatAmount(
              asyncStats.when(
                data: (stats) => stats.negativeSubscriptionsAmount,
                loading: () => 0,
                error: (error, stackTrace) => 0,
              ),
            ),
            icon: Icons.trending_down,
            valueColor: Colors.red.shade700,
          ),
        ),
      ],
    );
  }
}

/// Card affichant différentes statistiques sur les opérations du mois.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.valueColor,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: valueColor),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
