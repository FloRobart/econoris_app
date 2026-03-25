import 'package:econoris_app/ui/core/ui/operations/view_models/operation_stats_viewmodel.dart';
import 'package:econoris_app/ui/core/ui/utils/format_amount.dart';
import 'package:econoris_app/ui/core/ui/utils/format_date.dart';
import 'package:econoris_app/ui/core/ui/utils/possible_expense_color.dart';
import 'package:econoris_app/ui/core/ui/widgets/app_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget affichant des statistiques mensuelles sur les opérations.
class OperationMonthlyStats extends StatelessWidget {
  const OperationMonthlyStats({super.key});

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
                    'Statistiques du mois',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _TextDate(),
              const SizedBox(height: 14),
              _StatsTilesSection(),
              const SizedBox(height: 14),
              _PossibleExpensesBanner(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextDate extends ConsumerWidget {
  const _TextDate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final asyncStartDate = ref.watch(
      operationStatsProvider.select(
        (asyncStats) => asyncStats.whenData((stats) => stats.startMonthDate),
      ),
    );

    final asyncEndDate = ref.watch(
      operationStatsProvider.select(
        (asyncStats) => asyncStats.whenData((stats) => stats.endMonthDate),
      ),
    );

    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'Du '),
          TextSpan(
            text: asyncStartDate.when(
              data: (startDate) =>
                  formatDate(startDate, customFormat: 'dd MMMM yyyy') ??
                  'Mois inconnu',
              loading: () => '...',
              error: (error, stackTrace) =>
                  formatDate(
                    DateTime(DateTime.now().year, DateTime.now().month, 1),
                    customFormat: 'dd MMMM yyyy',
                  ) ??
                  'Mois inconnu',
            ),
            style:
                theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ) ??
                TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: ' au '),
          TextSpan(
            text: asyncEndDate.when(
              data: (endDate) =>
                  formatDate(endDate, customFormat: 'dd MMMM yyyy') ??
                  'Mois inconnu',
              loading: () => '...',
              error: (error, stackTrace) =>
                  formatDate(
                    DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
                    customFormat: 'dd MMMM yyyy',
                  ) ??
                  'Mois inconnu',
            ),
            style:
                theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ) ??
                TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Section affichant les différentes statistiques du mois sous forme de cartes.
class _StatsTilesSection extends ConsumerWidget {
  const _StatsTilesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncStats = ref.watch(operationStatsProvider);

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Opérations',
            value: asyncStats.when(
              data: (stats) => stats.monthlyOperationsCount.toString(),
              loading: () => '0',
              error: (error, stackTrace) => '0',
            ),
            subtitle: formatAmount(
              asyncStats.when(
                data: (stats) => stats.monthlyOperationsAmount,
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
              data: (stats) => stats.monthlyPositiveOperationsCount.toString(),
              loading: () => '0',
              error: (error, stackTrace) => '0',
            ),
            subtitle: formatAmount(
              asyncStats.when(
                data: (stats) => stats.monthlyPositiveOperationsAmount,
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
              data: (stats) => stats.monthlyNegativeOperationsCount.toString(),
              loading: () => '0',
              error: (error, stackTrace) => '0',
            ),
            subtitle: formatAmount(
              asyncStats.when(
                data: (stats) => stats.monthlyNegativeOperationsAmount,
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

/// Widget affichant une bannière avec le montant restant possible à dépenser pour le mois, avec une couleur dynamique en fonction de ce montant.
class _PossibleExpensesBanner extends ConsumerWidget {
  const _PossibleExpensesBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncMonthlyPossibleExpenses = ref.watch(
      operationStatsProvider.select(
        (asyncStats) =>
            asyncStats.whenData((stats) => stats.monthlyPossibleExpenses),
      ),
    );

    final asyncMonthlyPossibleExpensesRatio = ref.watch(
      operationStatsProvider.select(
        (asyncStats) =>
            asyncStats.whenData((stats) => stats.monthlyPossibleExpensesRatio),
      ),
    );

    final isPositive =
        asyncMonthlyPossibleExpenses
            .whenData((double amount) => amount >= 0)
            .value ??
        true;

    final bannerColor = getPossibleExpenseColor(
      (asyncMonthlyPossibleExpensesRatio
                  .whenData((double ratio) => ratio)
                  .value ??
              0) *
          100,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerColor.withValues(alpha: .15)),
      ),
      child: AppTooltip(
        message:
            'Vous pouvez dépenser ${((asyncMonthlyPossibleExpensesRatio.whenData((double ratio) => ratio).value ?? 0) * 100).toStringAsFixed(2)}% de votre budget mensuel',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                isPositive
                    ? Icons.wallet_outlined
                    : Icons.warning_amber_rounded,
                size: 18,
                color: bannerColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isPositive
                            ? 'Reste possible à dépenser'
                            : 'Dépassement du budget',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: bannerColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      asyncMonthlyPossibleExpenses.when(
                        data: (amount) => formatAmount(amount),
                        loading: () => formatAmount(0),
                        error: (error, stackTrace) => formatAmount(0),
                      ),
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: bannerColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
