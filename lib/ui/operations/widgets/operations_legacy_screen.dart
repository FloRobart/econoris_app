// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
// date formatting handled by OperationsTable

import '../../../data/services/global_data.dart';
import '../../../domain/models/operations/operation.dart';
import '../../../routing/routes.dart';
import '../../calendar/widgets/calendar_screen.dart';
import '../../core/ui/app_scaffold.dart';
import '../../core/ui/monthly_totals_banner.dart';
import 'add_operation_fab.dart';
import 'operation_dialogs.dart';
import 'operations_chart.dart';
import 'operations_table.dart';

class OperationsPage extends StatefulWidget {
  const OperationsPage({super.key});
  @override
  State<OperationsPage> createState() => _OperationsPageState();
}

class _OperationsPageState extends State<OperationsPage> {
  List<Operation> _operations = [];
  String? _jwt;
  bool _loading = false;
  String? _error;

  // UI state
  String _chartType = 'line';
  bool _tableView = true;
  String _search = '';
  String _sortField = 'operations_date';
  bool _sortAsc = false;
  String _categoryFilter = 'Tous';
  String _validateFilter = 'Tous'; // Tous / Validé / Non validé

  // Pagination
  int _page = 1;
  static const int _pageSize = 15;

  @override
  void initState() {
    super.initState();
    // Subscribe to GlobalData updates so this page uses GlobalData as the
    // single source of truth for operations. When GlobalData notifies we
    // refresh the local view from it.
    GlobalData.instance.refreshNotifier.addListener(_onGlobalDataRefresh);
    _init();
  }

  void _onGlobalDataRefresh() {
    if (!mounted) return;
    setState(() {
      _operations = GlobalData.instance.operations ?? [];
      _page = 1;
    });
  }

  @override
  void dispose() {
    try {
      GlobalData.instance.refreshNotifier.removeListener(_onGlobalDataRefresh);
    } catch (_) {}
    super.dispose();
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
          _page = 1;
        });
      } catch (e) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  // Use central GlobalData; refresh is done by re-calling _init

  List<Operation> get _filteredSorted {
    var list = _operations.where((op) {
      if (_categoryFilter != 'Tous' && op.category != _categoryFilter) {
        return false;
      }
      if (_validateFilter == 'Validé' && !op.isValidate) return false;
      if (_validateFilter == 'Non validé' && op.isValidate) return false;
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
      context: context,
      builder: (_) => OperationDetailDialog(operation: op),
    );
    if (result == 'deleted' || result == 'updated') await _init();
  }

  @override
  Widget build(BuildContext context) {
    final ops = _filteredSorted;
    // --- Monthly totals calculation ---
    // Revenue: sliding 1-month window (from same day previous month until today).
    // Expenses: keep calendar month (1st -> end of month).
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
    double revenueSliding = _operations
        .where((o) => o.amount > 0)
        .where(
          (o) =>
              (o.levyDate.isAfter(slidingStart) ||
                  o.levyDate.isAtSameMomentAs(slidingStart)) &&
              (o.levyDate.isBefore(now) || o.levyDate.isAtSameMomentAs(now)),
        )
        .fold(0.0, (s, o) => s + o.amount);

    double expenseCurrent = _operations
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
      revenueToShow = _operations
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

    String monthLabel(int y, int m) =>
        DateFormat.yMMMM('fr_FR').format(DateTime(y, m));
    final categories =
        ['Tous'] + _operations.map((e) => e.category).toSet().toList();
    final totalPages = (ops.length / _pageSize).ceil().clamp(1, 9999);
    final pageItems = ops
        .skip((_page - 1) * _pageSize)
        .take(_pageSize)
        .toList();
    final theme = Theme.of(context);

    return AppScaffold(
      currentIndex: 1,
      onProfilePressed: (ctx) =>
          Navigator.of(ctx).pushNamed(AppRoutes.profile).then((_) => _init()),
      floatingActionButton: AddOperationFab(operations: _operations),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await GlobalData.instance.fetchAll(_jwt ?? '');
                setState(() {
                  _operations = GlobalData.instance.operations ?? [];
                  _page = 1;
                });
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      // Totals — ligne par ligne (réutilisable)
                      MonthlyTotalsBanner(
                        revenueLabel:
                            'Revenu ${monthLabel(displayRevenueYear, displayRevenueMonth)}',
                        expenseLabel:
                            'Dépense ${monthLabel(currentYear, currentMonth)}',
                        revenueAmount: revenueToShow,
                        expenseAmount: expenseCurrent,
                      ),

                      const SizedBox(height: 12),

                      // Chart card with chart type selector
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.cardColor.withAlpha(
                                        (0.95 * 255).toInt(),
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: DropdownButton<String>(
                                      value: _chartType,
                                      dropdownColor: theme.cardColor,
                                      underline: const SizedBox.shrink(),
                                      items: ['line', 'bar', 'pie']
                                          .map(
                                            (s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(s),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => _chartType = v!),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${ops.length} opérations',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 220,
                                child: OperationsChart(
                                  operations: ops,
                                  chartType: _chartType,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Controls: search, filters, sort
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Rechercher par nom...',
                              ),
                              onChanged: (v) => setState(() {
                                _search = v;
                                _page = 1;
                              }),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            tooltip: 'Tri',
                            onSelected: (v) => setState(() {
                              _sortField = v;
                            }),
                            child: const Row(
                              children: [
                                Icon(Icons.sort),
                                SizedBox(width: 6),
                                Text('Tri'),
                              ],
                            ),
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'operations_date',
                                child: Text('Date'),
                              ),
                              PopupMenuItem(
                                value: 'operations_name',
                                child: Text('Nom'),
                              ),
                              PopupMenuItem(
                                value: 'operations_amount',
                                child: Text('Montant'),
                              ),
                              PopupMenuItem(
                                value: 'operations_id',
                                child: Text('ID'),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              _sortAsc
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                            ),
                            onPressed: () =>
                                setState(() => _sortAsc = !_sortAsc),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Text('Catégorie:'),
                          const SizedBox(width: 6),
                          DropdownButton<String>(
                            value: _categoryFilter,
                            items: categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() {
                              _categoryFilter = v!;
                              _page = 1;
                            }),
                          ),
                          const SizedBox(width: 12),
                          const Text('Validé:'),
                          const SizedBox(width: 6),
                          DropdownButton<String>(
                            value: _validateFilter,
                            items: ['Tous', 'Validé', 'Non validé']
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() {
                              _validateFilter = v!;
                              _page = 1;
                            }),
                          ),
                        ],
                      ),

                      // Toggle button moved to its own line to avoid overflow on small screens
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _tableView = !_tableView),
                            child: Text(
                              _tableView ? 'Vue calendrier' : 'Vue tableau',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // List / table (toggle between DataTable and calendar view)
                      if (_tableView) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: Card(
                              child: SingleChildScrollView(
                                // horizontal scrolling for wide tables; Card will now size to child
                                scrollDirection: Axis.horizontal,
                                child: OperationsTable(
                                  operations: pageItems,
                                  // pagination already applied by caller
                                  columns: const [
                                    'date',
                                    'name',
                                    'amount',
                                    'validated',
                                  ],
                                  onRowTap: (o) => _openDetail(o),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // When embedded in the operations page we disable CalendarPage's
                        // internal scrolling so the outer page scroll is used instead.
                        CalendarPage(
                          operations: ops,
                          onOperationTap: (op) => _openDetail(op),
                          noScroll: true,
                        ),
                      ],

                      // Pagination controls (mobile-friendly) - only for table view
                      if (_tableView)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: _page > 1
                                  ? () => setState(() => _page--)
                                  : null,
                            ),
                            Text('Page $_page / $totalPages'),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: _page < totalPages
                                  ? () => setState(() => _page++)
                                  : null,
                            ),
                          ],
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
