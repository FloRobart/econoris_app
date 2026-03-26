import 'package:econoris_app/domain/models/operations/operation.dart';

class OperationBodyViewmodel {
  OperationBodyViewmodel(List<Operation> operations) : _operations = operations;

  /* Attributes */
  final List<Operation> _operations;

  /* Variables */
  List<Operation>? _upComingOperations;
  List<Operation>? _pastOperations;

  /* Getters */
  List<Operation> get upComingOperations =>
      _upComingOperations ??= buildUpComingOperations();
  List<Operation> get pastOperations =>
      _pastOperations ??= buildPastOperations();

  /* Builders */
  /// Retourne les opérations à venir, triées par date croissante.
  List<Operation> buildUpComingOperations() {
    final now = DateTime.now();
    final upcoming =
        _operations.where((op) => op.levyDate.isAfter(now)).toList()
          ..sort((a, b) => b.levyDate.compareTo(a.levyDate));
    return upcoming.toList();
  }

  /// Retourne les opérations passées, triées par date décroissante.
  List<Operation> buildPastOperations() {
    final now = DateTime.now();
    final past = _operations.where((op) => op.levyDate.isBefore(now)).toList()
      ..sort((a, b) => b.levyDate.compareTo(a.levyDate));
    return past.toList();
  }
}
