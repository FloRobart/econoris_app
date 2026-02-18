import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/operations/operation.dart';
import '../../../routing/routes.dart';
import '../../calendar/widgets/calendar_screen.dart';
import '../../core/ui/app_scaffold.dart';
import '../../core/ui/monthly_totals_banner.dart';
import '../../operations/widgets/add_operation_fab.dart';
import '../../operations/widgets/operation_dialogs.dart';
import '../../operations/widgets/operations_chart.dart';
import '../../operations/widgets/operations_table.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    String monthYearLabel(int y, int m) => DateFormat.yMMMM('fr_FR').format(DateTime(y, m));

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
          final existsByFields = _operations.any(
            (o) =>
                o.levyDate == op.levyDate &&
                o.label == op.label &&
                o.amount == op.amount,
          );
          if (!existsById && !existsByFields) {
            _operations.insert(0, op);
          }
        }),
        operations: _operations,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // show error if present
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  // use card color from theme for better integration with light/dark modes
                                  color: theme.cardColor.withAlpha(
                                    (0.95 * 255).toInt(),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          theme.brightness == Brightness.light
                                          ? Colors.black12
                                          : Colors.black26,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: DropdownButton<String>(
                                  value: _chartType,
                                  dropdownColor: theme.cardColor,
                                  style: theme.textTheme.bodyMedium,
                                  underline: const SizedBox.shrink(),
                                  items: ['line', 'bar', 'pie']
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(
                                            s,
                                            style: theme.textTheme.bodyMedium,
                                          ),
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

                          // Chart area below the control
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

                  // Controls (search and manual add button removed)
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: _categoryFilter,
                        items: categories
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() {
                          _categoryFilter = v!;
                          _page = 1;
                        }),
                      ),
                      const SizedBox(width: 12),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () =>
                            setState(() => _tableView = !_tableView),
                        child: Text(
                          _tableView ? 'Vue calendrier' : 'Vue tableau',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _tableView
                      ? _buildTableView(pageItems)
                      : CalendarPage(
                          operations: ops,
                          onOperationTap: (op) => _openDetail(op),
                          noScroll: true,
                        ),

                  // Pagination controls (like OperationsPage) - only for table view
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
                ],
              ),
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
