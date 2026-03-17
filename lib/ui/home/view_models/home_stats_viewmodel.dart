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
    required this.totalAmount,
    required this.incomesTotal,
    required this.expensesTotal,
    required this.balance,
  });

  final int operationsCount;
  final double totalAmount;
  final double incomesTotal;
  final double expensesTotal;
  final double balance;

  factory HomeStatsViewModel.fromOperations(List<Operation> operations) {
    var totalAmount = 0.0;
    var incomesTotal = 0.0;
    var expensesTotal = 0.0;

    for (final operation in operations) {
      final amount = operation.amount;
      totalAmount += amount;

      if (amount >= 0) {
        incomesTotal += amount;
      } else {
        expensesTotal += amount;
      }
    }

    return HomeStatsViewModel(
      operationsCount: operations.length,
      totalAmount: totalAmount,
      incomesTotal: incomesTotal,
      expensesTotal: expensesTotal,
      balance: incomesTotal + expensesTotal,
    );
  }
}
