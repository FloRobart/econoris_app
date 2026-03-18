import 'package:econoris_app/ui/core/ui/widgets/card_container.dart';
import 'package:econoris_app/ui/home/view_models/home_stats_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeStats extends ConsumerWidget {
  const HomeStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ThemeData theme = Theme.of(context);
    final AsyncValue<HomeStatsViewModel> asyncHomeStats = ref.watch(
      homeStatsProvider,
    );

    /// Nombre total d'opérations
    final String operationsCountText = asyncHomeStats.when(
        data: (stats) => stats.operationsCount.toStringAsFixed(2),
        error: (error, stackTrace) => 'Erreur',
        loading: () => '...',
    );

    /// Montant total des opérations
    final String operationsAmountText = asyncHomeStats.when(
        data: (stats) => stats.operationsAmount.toStringAsFixed(2),
        error: (error, stackTrace) => 'Erreur',
        loading: () => '...',
    );

    /// Nombre d'opérations positives (revenus)
    final String positiveOperationsCountText = asyncHomeStats.when(
        data: (stats) => stats.positiveOperationsCount.toStringAsFixed(2),
        error: (error, stackTrace) => 'Erreur',
        loading: () => '...',
    );

    /// Montant total des opérations positives (revenus)
    final String positiveOperationsAmountText = asyncHomeStats.when(
        data: (stats) => stats.positiveOperationsAmount.toStringAsFixed(2),
        error: (error, stackTrace) => 'Erreur',
        loading: () => '...',
    );

    /// Nombre d'opérations négatives (dépenses)
    final String negativeOperationsCountText = asyncHomeStats.when(
        data: (stats) => stats.negativeOperationsCount.toStringAsFixed(2),
        error: (error, stackTrace) => 'Erreur',
        loading: () => '...',
    );

    /// Montant total des opérations négatives (dépenses)
    final String negativeOperationsAmountText = asyncHomeStats.when(
        data: (stats) => stats.negativeOperationsAmount.toStringAsFixed(2),
        error: (error, stackTrace) => 'Erreur',
        loading: () => '...',
    );

    /// Indice de gestion de l'argent (ratio entre revenus et dépenses)
    final String moneyManagementIndexText = asyncHomeStats.when(
        data: (stats) => stats.moneyManagementIndex.toStringAsFixed(2),
        error: (error, stackTrace) => 'Erreur',
        loading: () => '...',
    );

    /// Dépenses possibles (revenus - dépenses)
    final String possibleExpensesText = asyncHomeStats.when(
        data: (stats) => stats.possibleExpenses.toStringAsFixed(2),
        error: (error, stackTrace) => 'Erreur',
        loading: () => '...',
    );


    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Statistiques', style: theme.textTheme.titleMedium),

          const SizedBox(height: 12),

          Text('Nombre total d\'opérations : $operationsCountText'),
          Text('Montant total des opérations : $operationsAmountText'),
          Text('Nombre d\'opérations positives (revenus) : $positiveOperationsCountText'),
          Text('Montant total des opérations positives (revenus) : $positiveOperationsAmountText'),
          Text('Nombre d\'opérations négatives (dépenses) : $negativeOperationsCountText'),
          Text('Montant total des opérations négatives (dépenses) : $negativeOperationsAmountText'),
          Text('Indice de gestion de l\'argent : $moneyManagementIndexText'),
          Text('Dépenses possibles : $possibleExpensesText'),
        ],
      ),
    );
  }
}
