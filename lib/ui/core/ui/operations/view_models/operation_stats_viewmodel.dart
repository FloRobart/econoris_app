import 'package:econoris_app/config/constantes.dart';
import 'package:econoris_app/domain/models/operations/operation.dart';
import 'package:econoris_app/ui/home/view_models/home_body_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider derive unique qui calcule les statistiques de la home.
final operationStatsProvider = Provider<AsyncValue<OperationStatsViewModel>>((
  ref,
) {
  final asyncOperations = ref.watch(homeOperationsProvider);

  return asyncOperations.whenData(
    (operations) => OperationStatsViewModel.fromOperations(
      operations,
      ref.read(homeOperationsProvider.notifier).currentMonthOffset,
    ),
  );
});

/// Statistiques de synthese calculees en un seul parcours de la liste.
class OperationStatsViewModel {
  const OperationStatsViewModel({
    required this.startMonthDate,
    required this.nextMonthStartDate,

    required this.monthlyOperationsCount,
    required this.monthlyOperationsAmount,

    required this.monthlyPositiveOperationsCount,
    required this.monthlyPositiveOperationsAmount,

    required this.monthlyNegativeOperationsCount,
    required this.monthlyNegativeOperationsAmount,

    required this.monthlyMoneyManagementIndex,
    required this.monthlyPossibleExpenses,
  });

  final DateTime startMonthDate;
  final DateTime nextMonthStartDate;

  final int monthlyOperationsCount;
  final double monthlyOperationsAmount;

  final int monthlyPositiveOperationsCount;
  final double monthlyPositiveOperationsAmount;

  final int monthlyNegativeOperationsCount;
  final double monthlyNegativeOperationsAmount;

  final double monthlyMoneyManagementIndex;
  final double monthlyPossibleExpenses;

  /// Calcule les statistiques à partir de la liste d'opérations en un seul parcours.
  factory OperationStatsViewModel.fromOperations(
    List<Operation> operations,
    int monthOffset,
  ) {
    final now = DateTime.now();
    final startMonthDate = _resolveFinancialMonthStartDate(
      operations,
      monthOffset,
    );
    var nextMonthStartDate = _resolveFinancialMonthStartDate(
      operations,
      monthOffset + 1,
    ).subtract(const Duration(days: 1));

    double operationsAmount = 0;
    int operationsCount = 0;

    int positiveOperationsCount = 0;
    double positiveOperationsAmount = 0;

    int negativeOperationsCount = 0;
    double negativeOperationsAmount = 0;

    double moneyManagementIndex = 0;

    for (final operation in operations) {
      if (operation.levyDate.isBefore(startMonthDate) ||
          !operation.levyDate.isBefore(nextMonthStartDate)) {
        continue;
      }

      operationsCount++;
      operationsAmount += operation.amount;

      if (operation.amount > 0) {
        positiveOperationsAmount += operation.amount;
        positiveOperationsCount++;
      } else {
        negativeOperationsAmount += operation.amount;
        negativeOperationsCount++;
      }
    }

    moneyManagementIndex =
        positiveOperationsAmount /
        (negativeOperationsAmount.abs() != 0
            ? negativeOperationsAmount.abs()
            : 1);

    double possibleExpenses =
        positiveOperationsAmount + negativeOperationsAmount;

    /// On retourne un objet de stats avec tous les calculs déjà faits pour éviter de les refaire dans le widget.
    return OperationStatsViewModel(
      startMonthDate: startMonthDate,
      nextMonthStartDate: nextMonthStartDate,
      monthlyOperationsCount: operationsCount,
      monthlyOperationsAmount: operationsAmount,
      monthlyPositiveOperationsCount: positiveOperationsCount,
      monthlyPositiveOperationsAmount: positiveOperationsAmount,
      monthlyNegativeOperationsCount: negativeOperationsCount,
      monthlyNegativeOperationsAmount: negativeOperationsAmount,
      monthlyMoneyManagementIndex: moneyManagementIndex,
      monthlyPossibleExpenses: possibleExpenses,
    );
  }

  /// Détermine la date de début du mois financier en se basant sur les opérations positives (salaires) les plus récentes dans une fenêtre de recherche autour de la date théorique du début du mois financier.
  static DateTime _resolveFinancialMonthStartDate(
    List<Operation> operations,
    int monthOffset,
  ) {
    final now = DateTime.now();

    /// On définit une fenêtre de recherche autour de la date théorique du début du mois financier pour trouver la date réelle de début du mois financier.
    final windowStart = DateTime(
      now.year,
      now.month + monthOffset - 1,
      now.day,
    ).subtract(const Duration(days: Constantes.salaryWindowSafetyMarginDays));

    /// On définit la date de fin de la fenêtre de recherche. En réalité, on cherche la date de début du mois financier suivant à laquelle on soustrait un jour pour trouver la date de fin du mois financier actuel.
    final windowEnd = DateTime(
      now.year,
      now.month + monthOffset,
      now.day,
    ).add(const Duration(days: Constantes.salaryWindowSafetyMarginDays));

    /// On filtre les opérations pour ne garder que celles qui sont dans la fenêtre de recherche et qui sont positives (les salaires). Ensuite, on trie ces opérations par date pour trouver la plus récente.
    final positiveOperationsInWindow =
        operations
            .where(
              (operation) =>
                  operation.amount > 0 &&
                  operation.levyDate.isAfter(windowStart) &&
                  operation.levyDate.isBefore(windowEnd),
            )
            .toList()
          ..sort((a, b) => a.levyDate.compareTo(b.levyDate));

    /// Si aucune opération positive n'est trouvée dans la fenêtre de recherche, on retourne la date théorique du début du mois financier, c'est à dire le premier de la date actuelle avec le décalage de mois appliqué.
    if (positiveOperationsInWindow.isEmpty) {
      return DateTime(now.year, now.month + monthOffset);
    }

    /// On récupère l'opération avec le montant positif le plus élevé dans la fenêtre de recherche. En cas d'égalité sur le montant, on prend l'opération la plus récente. On considère que c'est cette opération qui correspond au salaire et donc au début du mois financier.
    final operationWithMaxAmount = positiveOperationsInWindow.reduce((
      currentMax,
      operation,
    ) {
      if (operation.amount > currentMax.amount) {
        return operation;
      }
      if (operation.amount == currentMax.amount &&
          operation.levyDate.isAfter(currentMax.levyDate)) {
        return operation;
      }
      return currentMax;
    });

    return operationWithMaxAmount.levyDate;
  }
}
