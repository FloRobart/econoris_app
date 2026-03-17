import 'package:econoris_app/ui/core/ui/widgets/card_container.dart';
import 'package:econoris_app/ui/home/view_models/home_stats_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeStats extends ConsumerWidget {
  const HomeStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<HomeStatsViewModel> asyncHomeStats = ref.watch(
      homeStatsProvider,
    );

    final String totalAmountText = asyncHomeStats.when(
      data: (stats) => stats.totalAmount.toStringAsFixed(2),
      error: (error, stackTrace) => 'Erreur',
      loading: () => '...',
    );

    final String operationsCountText = asyncHomeStats.when(
      data: (stats) => stats.operationsCount.toString(),
      error: (error, stackTrace) => 'Erreur',
      loading: () => '...',
    );

    final String balanceText = asyncHomeStats.when(
      data: (stats) => stats.balance.toStringAsFixed(2),
      error: (error, stackTrace) => 'Erreur',
      loading: () => '...',
    );

    final String incomesTotalText = asyncHomeStats.when(
      data: (stats) => stats.incomesTotal.toStringAsFixed(2),
      error: (error, stackTrace) => 'Erreur',
      loading: () => '...',
    );

    final String expensesTotalText = asyncHomeStats.when(
      data: (stats) => stats.expensesTotal.toStringAsFixed(2),
      error: (error, stackTrace) => 'Erreur',
      loading: () => '...',
    );

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Statistiques', style: Theme.of(context).textTheme.titleMedium),

          const SizedBox(height: 12),

          Text('Total: $totalAmountText'),
          Text('Nombre d\'opérations: $operationsCountText'),
          Text('Balance: $balanceText'),
          Text('Incomes: $incomesTotalText'),
          Text('Expenses: $expensesTotalText'),
        ],
      ),
    );
  }
}
