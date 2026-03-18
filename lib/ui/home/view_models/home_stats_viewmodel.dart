import 'package:econoris_app/domain/models/operations/operation.dart';
import 'package:econoris_app/ui/home/view_models/home_body_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider derive unique qui calcule les statistiques de la home.
final homeStatsProvider = Provider<AsyncValue<HomeStatsViewModel>>((ref) {
  final asyncOperations = ref.watch(homeOperationsProvider);

  return asyncOperations.whenData(
    (operations) => HomeStatsViewModel.fromOperations(operations),
  );
});

/// Statistiques de synthese calculees en un seul parcours de la liste.
class HomeStatsViewModel {
  const HomeStatsViewModel({
    required this.operationsCount,
    required this.operationsAmount,

    required this.positiveOperationsCount,
    required this.positiveOperationsAmount,

    required this.negativeOperationsCount,
    required this.negativeOperationsAmount,

    required this.moneyManagementIndex,
    required this.possibleExpenses,
  });

  final int operationsCount;
  final double operationsAmount;

  final int positiveOperationsCount;
  final double positiveOperationsAmount;

  final int negativeOperationsCount;
  final double negativeOperationsAmount;

  final double moneyManagementIndex;
  final double possibleExpenses;

  /// Calcule les statistiques à partir de la liste d'opérations en un seul parcours.
  factory HomeStatsViewModel.fromOperations(List<Operation> operations) {
    double operationsAmount = 0;

    int positiveOperationsCount = 0;
    double positiveOperationsAmount = 0;

    int negativeOperationsCount = 0;
    double negativeOperationsAmount = 0;

    double moneyManagementIndex = 0;

    for (final operation in operations) {
      operationsAmount += operation.amount;


      if (operation.amount > 0) {
        positiveOperationsAmount += operation.amount;
        positiveOperationsCount++;
      } else {
        negativeOperationsAmount += operation.amount;
        negativeOperationsCount++;
      }
    }

    moneyManagementIndex = negativeOperationsAmount.abs() != 0
        ? (positiveOperationsAmount / negativeOperationsAmount.abs())
        : 0;

    double possibleExpenses = positiveOperationsAmount + negativeOperationsAmount;

    /// On retourne un objet de stats avec tous les calculs déjà faits pour éviter de les refaire dans le widget.
    return HomeStatsViewModel(
      operationsCount: operations.length,
      operationsAmount: operationsAmount,
      positiveOperationsCount: positiveOperationsCount,
      positiveOperationsAmount: positiveOperationsAmount,
      negativeOperationsCount: negativeOperationsCount,
      negativeOperationsAmount: negativeOperationsAmount,
      moneyManagementIndex: moneyManagementIndex,
      possibleExpenses: possibleExpenses,
    );
  }
}
