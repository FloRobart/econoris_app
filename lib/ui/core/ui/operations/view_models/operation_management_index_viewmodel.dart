import 'package:econoris_app/ui/core/ui/operations/view_models/operation_stats_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider pour le ViewModel de l'index de gestion des opérations.
final operationManagementIndexViewmodelProvider =
    Provider<AsyncValue<OperationManagementIndexViewmodel>>((ref) {
      final asyncMoneyManagementIndex = ref.watch(
        operationStatsProvider.select(
          (asyncStats) =>
              asyncStats.whenData((stats) => stats.monthlyMoneyManagementIndex),
        ),
      );

      return asyncMoneyManagementIndex.whenData(
        (moneyManagementIndex) => OperationManagementIndexViewmodel(
          moneyManagementIndex: moneyManagementIndex,
        ),
      );
    });

/// ViewModel pour l'index de gestion des opérations, qui contient uniquement l'indice de gestion d'argent.
class OperationManagementIndexViewmodel {
  OperationManagementIndexViewmodel({required this.moneyManagementIndex});

  final double moneyManagementIndex;

  /// Calcule le pourcentage de l'indice de gestion d'argent pour l'affichage.
  double get moneyManagementIndexPercentage => moneyManagementIndex * 100;
}
