import 'package:econoris_app/ui/core/ui/widgets/card_container.dart';
import 'package:econoris_app/ui/home/view_models/home_stats_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeStats extends ConsumerWidget {
  const HomeStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final AsyncValue<HomeStatsViewModel> asyncHomeStats = ref.watch(
      homeStatsProvider,
    );

    return SizedBox(
      width: double.infinity,
      child: CardContainer(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Statistiques',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            asyncHomeStats.when(
              data: (stats) => _StatsGrid(stats: stats),
              error: (error, stackTrace) =>
                  _StatsError(message: error.toString()),
              loading: () => const _StatsLoading(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final HomeStatsViewModel stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tiles = <_StatTileData>[
      _StatTileData(
        title: 'Operations',
        value: stats.operationsCount.toString(),
        icon: Icons.receipt_long_outlined,
        color: theme.colorScheme.primary,
      ),
      _StatTileData(
        title: 'Montant total',
        value: _formatCurrency(stats.operationsAmount),
        icon: Icons.account_balance_wallet_outlined,
        color: theme.colorScheme.secondary,
      ),
      _StatTileData(
        title: 'Revenus',
        value: '${stats.positiveOperationsCount} ops',
        icon: Icons.trending_up,
        color: Colors.green.shade700,
      ),
      _StatTileData(
        title: 'Total revenus',
        value: _formatCurrency(stats.positiveOperationsAmount),
        icon: Icons.arrow_circle_up_outlined,
        color: Colors.green.shade700,
      ),
      _StatTileData(
        title: 'Depenses',
        value: '${stats.negativeOperationsCount} ops',
        icon: Icons.trending_down,
        color: theme.colorScheme.error,
      ),
      _StatTileData(
        title: 'Total depenses',
        value: _formatCurrency(-stats.negativeOperationsAmount.abs()),
        icon: Icons.arrow_circle_down_outlined,
        color: theme.colorScheme.error,
      ),
      _StatTileData(
        title: 'Indice de gestion',
        value: stats.moneyManagementIndex.toStringAsFixed(2),
        icon: Icons.speed_outlined,
        color: theme.colorScheme.tertiary,
      ),
      _StatTileData(
        title: 'Budget disponible',
        value: _formatCurrency(stats.possibleExpenses),
        icon: Icons.savings_outlined,
        color: stats.possibleExpenses >= 0
            ? Colors.green.shade700
            : theme.colorScheme.error,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final maxWidth = constraints.maxWidth;
        final columns = maxWidth >= 950 ? 4 : (maxWidth >= 620 ? 2 : 1);
        final tileWidth = (maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: tiles
              .map(
                (tile) => SizedBox(
                  width: tileWidth,
                  child: _StatTile(data: tile),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.data});

  final _StatTileData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: data.color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(data.icon, size: 20, color: data.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.78,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsLoading extends StatelessWidget {
  const _StatsLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _StatsError extends StatelessWidget {
  const _StatsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Impossible de charger les statistiques. $message',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTileData {
  const _StatTileData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

String _formatCurrency(double value) {
  final prefix = value > 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(2)} €';
}
