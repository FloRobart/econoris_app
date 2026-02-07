import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/operation.dart';
import '../../../services/global_data_impl.dart';
import 'operations_state.dart';

/// Provider du ViewModel des operations.
final operationsControllerProvider =
    AutoDisposeNotifierProvider<OperationsController, OperationsState>(
        OperationsController.new);

/// ViewModel (MVVM) responsable du chargement et des interactions UI.
class OperationsController extends AutoDisposeNotifier<OperationsState> {
  static const int _pageSize = 15;
  String? _jwt;

  @override
  OperationsState build() {
    // Abonnement aux mises a jour du store global.
    GlobalData.instance.refreshNotifier.addListener(_onGlobalDataRefresh);
    ref.onDispose(
      () => GlobalData.instance.refreshNotifier.removeListener(
        _onGlobalDataRefresh,
      ),
    );

    // Chargement initial sans bloquer la construction.
    _load();
    return OperationsState.initial();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null, page: 1);
    try {
      final prefs = await SharedPreferences.getInstance();
      _jwt = prefs.getString('jwt');
      final jwt = _jwt;
      if (jwt == null || jwt.isEmpty) {
        state = state.copyWith(isLoading: false, error: 'Non authentifie');
        return;
      }

      await GlobalData.instance.ensureData(jwt);
      state = state.copyWith(
        operations: GlobalData.instance.operations ?? <Operation>[],
        isLoading: false,
        error: null,
        page: 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    final jwt = _jwt;
    if (jwt == null || jwt.isEmpty) {
      state = state.copyWith(error: 'Non authentifie');
      return;
    }

    state = state.copyWith(isLoading: true, error: null, page: 1);
    try {
      await GlobalData.instance.fetchAll(jwt);
      state = state.copyWith(
        operations: GlobalData.instance.operations ?? <Operation>[],
        isLoading: false,
        error: null,
        page: 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setChartType(String value) {
    state = state.copyWith(chartType: value);
  }

  void toggleTableView() {
    state = state.copyWith(tableView: !state.tableView);
  }

  void setSearch(String value) {
    state = state.copyWith(search: value, page: 1);
  }

  void setSortField(String value) {
    state = state.copyWith(sortField: value);
  }

  void toggleSortDirection() {
    state = state.copyWith(sortAsc: !state.sortAsc);
  }

  void setCategoryFilter(String value) {
    state = state.copyWith(categoryFilter: value, page: 1);
  }

  void setValidateFilter(String value) {
    state = state.copyWith(validateFilter: value, page: 1);
  }

  void setPage(int value) {
    state = state.copyWith(page: value);
  }

  void handleOperationCreated(Operation operation) {
    final current = List<Operation>.from(state.operations);

    // Evite les doublons en comparant id ou combinaison de champs.
    final existsById =
        operation.id != 0 && current.any((o) => o.id == operation.id);
    final existsByFields = current.any(
      (o) =>
          o.levyDate == operation.levyDate &&
          o.label == operation.label &&
          o.amount == operation.amount,
    );

    if (!existsById && !existsByFields) {
      current.insert(0, operation);
      state = state.copyWith(operations: current);
    }
  }

  /// Liste filtree + triee selon l'etat UI.
  List<Operation> filteredSortedOperations() {
    final list = state.operations.where((op) {
      if (state.categoryFilter != 'Tous' &&
          op.category != state.categoryFilter) {
        return false;
      }
      if (state.validateFilter == 'Validé' && !op.isValidate) {
        return false;
      }
      if (state.validateFilter == 'Non validé' && op.isValidate) {
        return false;
      }
      if (state.search.isNotEmpty) {
        final s = state.search.toLowerCase();
        return op.label.toLowerCase().contains(s) ||
            (op.source ?? '').toLowerCase().contains(s) ||
            (op.destination ?? '').toLowerCase().contains(s);
      }
      return true;
    }).toList();

    list.sort((a, b) {
      int res = 0;
      switch (state.sortField) {
        case 'operations_amount':
          res = a.amount.compareTo(b.amount);
          break;
        case 'operations_name':
          res = a.label.compareTo(b.label);
          break;
        case 'operations_date':
          res = a.levyDate.compareTo(b.levyDate);
          break;
        case 'operations_id':
          res = a.id.compareTo(b.id);
          break;
        default:
          res = a.levyDate.compareTo(b.levyDate);
      }
      return state.sortAsc ? res : -res;
    });

    return list;
  }

  /// Catagories distinctes pour le filtre.
  List<String> categories() {
    final categories = state.operations.map((e) => e.category).toSet().toList();
    categories.sort();
    return <String>['Tous', ...categories];
  }

  /// Calcule les totaux mensuels pour la banniere.
  OperationsTotals buildTotals() {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    DateTime startOfSlidingMonth(DateTime ref) {
      final int d = ref.day;
      DateTime candidate = DateTime(ref.year, ref.month - 1, d);
      if (candidate.month == ref.month) {
        candidate = DateTime(ref.year, ref.month, 0);
      }
      return candidate;
    }

    final DateTime slidingStart = startOfSlidingMonth(now);
    double revenueSliding = state.operations
        .where((o) => o.amount > 0)
        .where(
          (o) =>
              (o.levyDate.isAfter(slidingStart) ||
                  o.levyDate.isAtSameMomentAs(slidingStart)) &&
              (o.levyDate.isBefore(now) || o.levyDate.isAtSameMomentAs(now)),
        )
        .fold(0.0, (s, o) => s + o.amount);

    double expenseCurrent = state.operations
        .where(
          (o) =>
              o.levyDate.year == currentYear &&
              o.levyDate.month == currentMonth &&
              o.amount < 0,
        )
        .fold(0.0, (s, o) => s + o.amount.abs());

    int displayRevenueYear = currentYear;
    int displayRevenueMonth = currentMonth;
    double revenueToShow = revenueSliding;

    if (revenueSliding == 0) {
      final DateTime prevEnd = slidingStart;
      final DateTime prevStart = startOfSlidingMonth(prevEnd);
      revenueToShow = state.operations
          .where((o) => o.amount > 0)
          .where(
            (o) =>
                (o.levyDate.isAfter(prevStart) ||
                    o.levyDate.isAtSameMomentAs(prevStart)) &&
                (o.levyDate.isBefore(prevEnd) ||
                    o.levyDate.isAtSameMomentAs(prevEnd)),
          )
          .fold(0.0, (s, o) => s + o.amount);

      displayRevenueYear = prevEnd.year;
      displayRevenueMonth = prevEnd.month;
    }

    return OperationsTotals(
      revenueAmount: revenueToShow,
      expenseAmount: expenseCurrent,
      revenueYear: displayRevenueYear,
      revenueMonth: displayRevenueMonth,
      expenseYear: currentYear,
      expenseMonth: currentMonth,
    );
  }

  /// Elements de page apres pagination.
  List<Operation> pageItems(List<Operation> filtered) {
    return filtered.skip((state.page - 1) * _pageSize).take(_pageSize).toList();
  }

  int totalPages(int itemsCount) {
    return (itemsCount / _pageSize).ceil().clamp(1, 9999);
  }

  void _onGlobalDataRefresh() {
    state = state.copyWith(
      operations: GlobalData.instance.operations ?? <Operation>[],
      page: 1,
    );
  }
}

/// Valeurs derivees pour la banniere des totaux.
class OperationsTotals {
  final double revenueAmount;
  final double expenseAmount;
  final int revenueYear;
  final int revenueMonth;
  final int expenseYear;
  final int expenseMonth;

  const OperationsTotals({
    required this.revenueAmount,
    required this.expenseAmount,
    required this.revenueYear,
    required this.revenueMonth,
    required this.expenseYear,
    required this.expenseMonth,
  });
}
