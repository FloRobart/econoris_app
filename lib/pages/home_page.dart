// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
// date formatting used for totals

import '../models/operation.dart';
import '../services/global_data_impl.dart';
import '../widgets/app_scaffold.dart';
import '../routing/app_routes.dart';
import '../widgets/operations_chart.dart';
import '../pages/calendar_page.dart';
import '../widgets/operation_dialogs.dart';
import '../widgets/add_operation_fab.dart';
import '../widgets/operations_table.dart';
import '../widgets/monthly_totals_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Operation> _operations = [];
  String? _jwt;
  bool _loading = false;
  String? _error;

  // UI state
  bool _tableView = true;
  String _chartType = 'line';
  final String _search = '';
  final String _sortField = 'operations_date';
  final bool _sortAsc = false;
  String _categoryFilter = 'Tous';
  // Pagination
  int _page = 1;
  static const int _pageSize = 15;
  // show only the 15 last operations (no pagination)
  // FAB open state for the three small bubbles (moved to reusable widget)

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _jwt = sp.getString('jwt');
    });
    if (_jwt != null) {
      setState(() {
        _loading = true;
        _error = null;
      });
      try {
        await GlobalData.instance.ensureData(_jwt!);
        setState(() {
          _operations = GlobalData.instance.operations ?? [];
          _loading = false;
        });
      } catch (e) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  // If an operation was modified/deleted we re-init the page to refresh
  // data from the central store.

  List<Operation> get _filteredOperations {
    var list = _operations.where((op) {
      if (_categoryFilter != 'Tous' && op.category != _categoryFilter) {
        return false;
      }
      if (_search.isNotEmpty) {
        final s = _search.toLowerCase();
        return op.label.toLowerCase().contains(s) ||
            (op.source ?? '').toLowerCase().contains(s) ||
            (op.destination ?? '').toLowerCase().contains(s);
      }
      return true;
    }).toList();

    list.sort((a, b) {
      int res = 0;
      switch (_sortField) {
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
      return _sortAsc ? res : -res;
    });

    return list;
  }

  void _openDetail(Operation op) async {
    final result = await showDialog<String>(
        context: context, builder: (_) => OperationDetailDialog(operation: op));
    if (result == 'deleted' || result == 'updated') await _init();
  }

  @override
  Widget build(BuildContext context) {
    final ops = _filteredOperations;
    final categories =
        ['Tous'] + _operations.map((e) => e.category).toSet().toList();
    final theme = Theme.of(context);
    final totalPages = (ops.length / _pageSize).ceil().clamp(1, 9999);
    final pageItems =
        ops.skip((_page - 1) * _pageSize).take(_pageSize).toList();

    // --- Monthly totals calculation (same banner as OperationsPage) ---
    // Revenue: sliding 1-month window (from same day previous month until today).
    // Expenses: keep calendar month (1st -> end of month).
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    // compute start date as the same day last month; if that day doesn't exist
    // in the previous month, use the last day of the previous month.
    DateTime startOfSlidingMonth(DateTime ref) {
      final int d = ref.day;
      DateTime candidate = DateTime(ref.year, ref.month - 1, d);
      // if overflow happened, DateTime will roll forward into the current month
      if (candidate.month == ref.month) {
        candidate =
            DateTime(ref.year, ref.month, 0); // last day of previous month
      }
      return candidate;
    }

    final DateTime slidingStart = startOfSlidingMonth(now);
    double revenueSliding = _operations
        .where((o) => o.amount > 0)
        .where((o) =>
            (o.levyDate.isAfter(slidingStart) ||
                o.levyDate.isAtSameMomentAs(slidingStart)) &&
            (o.levyDate.isBefore(now) || o.levyDate.isAtSameMomentAs(now)))
        .fold(0.0, (s, o) => s + o.amount);

    // expenses stay in current calendar month
    double expenseCurrent = _operations
        .where((o) =>
            o.levyDate.year == currentYear &&
            o.levyDate.month == currentMonth &&
            o.amount < 0)
        .fold(0.0, (s, o) => s + o.amount.abs());

    // If sliding window has no revenue, fallback to previous sliding window
    int displayRevenueYear = currentYear;
    int displayRevenueMonth = currentMonth;
    double revenueToShow = revenueSliding;
    if (revenueSliding == 0) {
      final DateTime prevEnd = slidingStart;
      final DateTime prevStart = startOfSlidingMonth(prevEnd);
      revenueToShow = _operations
          .where((o) => o.amount > 0)
          .where((o) =>
              (o.levyDate.isAfter(prevStart) ||
                  o.levyDate.isAtSameMomentAs(prevStart)) &&
              (o.levyDate.isBefore(prevEnd) ||
                  o.levyDate.isAtSameMomentAs(prevEnd)))
          .fold(0.0, (s, o) => s + o.amount);

      // display label for the previous period (use end month of that window)
      displayRevenueYear = prevEnd.year;
      displayRevenueMonth = prevEnd.month;
    }

    String monthLabel(int y, int m) =>
        DateFormat.yMMMM('fr_FR').format(DateTime(y, m));

    return AppScaffold(
      currentIndex: 0,
      onProfilePressed: (ctx) =>
          Navigator.of(ctx).pushNamed(AppRoutes.profile).then((_) => _init()),
      floatingActionButton: AddOperationFab(
        onOperationCreated: (op) => setState(() {
          // avoid duplicate insertion: the AddOperationFab also updates
          // GlobalData which may already contain the created operation.
          // Check by id when available, otherwise fallback to a
          // heuristic (same date+label+amount).
          final existsById =
              op.id != 0 && _operations.any((o) => o.id == op.id);
          final existsByFields = _operations.any((o) =>
              o.levyDate == op.levyDate &&
              o.label == op.label &&
              o.amount == op.amount);
          if (!existsById && !existsByFields) {
            _operations.insert(0, op);
          }
        }),
        operations: _operations,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(children: [
                // show error if present
                if (_error != null)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.red))),
                // Totals — réutilisable
                MonthlyTotalsBanner(
                  revenueLabel:
                      'Revenu ${monthLabel(displayRevenueYear, displayRevenueMonth)}',
                  expenseLabel:
                      'Dépense ${monthLabel(currentYear, currentMonth)}',
                  revenueAmount: revenueToShow,
                  expenseAmount: expenseCurrent,
                ),

                const SizedBox(height: 12),

                // Chart area
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Control aligned top-left of the Card (only the dropdown, no label)
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              // use card color from theme for better integration with light/dark modes
                              color: theme.cardColor
                                  .withAlpha((0.95 * 255).toInt()),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.brightness == Brightness.light
                                      ? Colors.black12
                                      : Colors.black26,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: DropdownButton<String>(
                              value: _chartType,
                              dropdownColor: theme.cardColor,
                              style: theme.textTheme.bodyMedium,
                              underline: const SizedBox.shrink(),
                              items: ['line', 'bar', 'pie']
                                  .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s,
                                          style: theme.textTheme.bodyMedium)))
                                  .toList(),
                              onChanged: (v) => setState(() => _chartType = v!),
                            ),
                          ),
                          const Spacer(),
                          Text('${ops.length} opérations',
                              style: theme.textTheme.bodyMedium),
                        ]),

                        const SizedBox(height: 8),

                        // Chart area below the control
                        SizedBox(
                          height: 220,
                          child: OperationsChart(
                              operations: ops, chartType: _chartType),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Controls (search and manual add button removed)
                Row(children: [
                  DropdownButton<String>(
                      value: _categoryFilter,
                      items: categories
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() {
                            _categoryFilter = v!;
                            _page = 1;
                          })),
                  const SizedBox(width: 12),
                  const Spacer(),
                  ElevatedButton(
                      onPressed: () => setState(() => _tableView = !_tableView),
                      child:
                          Text(_tableView ? 'Vue calendrier' : 'Vue tableau'))
                ]),

                const SizedBox(height: 12),

                _tableView
                    ? _buildTableView(pageItems)
                    : CalendarPage(
                        operations: ops,
                        onOperationTap: (op) => _openDetail(op),
                        noScroll: true),

                // Pagination controls (like OperationsPage) - only for table view
                if (_tableView)
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed:
                            _page > 1 ? () => setState(() => _page--) : null),
                    Text('Page $_page / $totalPages'),
                    IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _page < totalPages
                            ? () => setState(() => _page++)
                            : null),
                  ]),
              ]),
            ),
    );
  }

  Widget _buildTableView(List<Operation> ops) {
    // No pagination here: let the table widget limit rows via maxItems
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        child: SingleChildScrollView(
          // horizontal scrolling for wide tables
          scrollDirection: Axis.horizontal,
          child: OperationsTable(
            operations: ops,
            maxItems: 15,
            columns: const ['date', 'name', 'amount', 'validated'],
            onRowTap: (o) => _openDetail(o),
          ),
        ),
      ),
    );
  }
}
