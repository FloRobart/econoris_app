import '../../../domain/models/operations/operation.dart';

/// Etat immutable pour la page des operations.
class OperationsState {
  static const Object _noChange = Object();

  final List<Operation> operations;
  final bool isLoading;
  final String? error;

  // Etat UI.
  final String chartType;
  final bool tableView;
  final String search;
  final String sortField;
  final bool sortAsc;
  final String categoryFilter;
  final String validateFilter;
  final int page;

  const OperationsState({
    required this.operations,
    required this.isLoading,
    required this.error,
    required this.chartType,
    required this.tableView,
    required this.search,
    required this.sortField,
    required this.sortAsc,
    required this.categoryFilter,
    required this.validateFilter,
    required this.page,
  });

  factory OperationsState.initial() {
    return const OperationsState(
      operations: <Operation>[],
      isLoading: false,
      error: null,
      chartType: 'line',
      tableView: true,
      search: '',
      sortField: 'operations_date',
      sortAsc: false,
      categoryFilter: 'Tous',
      validateFilter: 'Tous',
      page: 1,
    );
  }

  OperationsState copyWith({
    List<Operation>? operations,
    bool? isLoading,
    Object? error = _noChange,
    String? chartType,
    bool? tableView,
    String? search,
    String? sortField,
    bool? sortAsc,
    String? categoryFilter,
    String? validateFilter,
    int? page,
  }) {
    return OperationsState(
      operations: operations ?? this.operations,
      isLoading: isLoading ?? this.isLoading,
      error: error == _noChange ? this.error : error as String?,
      chartType: chartType ?? this.chartType,
      tableView: tableView ?? this.tableView,
      search: search ?? this.search,
      sortField: sortField ?? this.sortField,
      sortAsc: sortAsc ?? this.sortAsc,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      validateFilter: validateFilter ?? this.validateFilter,
      page: page ?? this.page,
    );
  }
}
