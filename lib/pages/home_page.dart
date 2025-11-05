// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../models/operation.dart';
import '../services/api_service.dart';
import '../widgets/app_scaffold.dart';
import '../navigation/app_routes.dart';
import '../widgets/operations_chart.dart';
import '../pages/calendar_page.dart';
import '../widgets/operation_dialogs.dart';
import '../widgets/add_operation_fab.dart';

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
  String _search = '';
  final String _sortField = 'operations_date';
  final bool _sortAsc = false;
  String _categoryFilter = 'Tous';
  // show only the 15 last operations (no pagination)
  // FAB open state for the three small bubbles (moved to reusable widget)

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final sp = await SharedPreferences.getInstance();
    setState(() { _jwt = sp.getString('jwt'); });
    await _fetchOperations();
  }

  Future<void> _fetchOperations() async {
    if (_jwt == null) {
      // no JWT -> nothing to fetch. ensure loading is false to avoid stuck spinner.
      setState(() { _loading = false; _error = null; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final resp = await ApiService.getOperations(_jwt!);

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (resp.body.isEmpty) {
          setState(() { _operations = []; _loading = false; });
          return;
        }
        final parsed = jsonDecode(resp.body);
        List<dynamic> list;
        if (parsed is List) {
          list = parsed;
        } else if (parsed is Map && parsed.containsKey('rows') && parsed['rows'] is List) {
          list = parsed['rows'];
        } else if (parsed is Map && parsed.containsKey('data') && parsed['data'] is List) {
          list = parsed['data'];
        } else if (parsed is Map && parsed.containsKey('operations') && parsed['operations'] is List) {
          list = parsed['operations'];
        } else {
          // fallback: if it's a map representing a single operation, wrap it
          if (parsed is Map) list = [parsed]; else list = [];
        }
        final ops = list.map((e) => Operation.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  ops.sort((a, b) => b.levyDate.compareTo(a.levyDate));
        setState(() { _operations = ops; _loading = false; });
      } else {
        String msg = 'Erreur (${resp.statusCode})';
        try {
          final body = resp.body;
          if (body.isNotEmpty) {
            final parsed = jsonDecode(body);
            if (parsed is Map && parsed.containsKey('error')) {
              msg = parsed['error'].toString();
            } else {
              msg = body;
            }
          }
        } catch (e) {
          // keep default msg if parsing fails
        }
        setState(() { _error = msg; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Operation> get _filteredOperations {
    var list = _operations.where((op) {
  if (_categoryFilter != 'Tous' && op.category != _categoryFilter) return false;
      if (_search.isNotEmpty) {
        final s = _search.toLowerCase();
  return op.label.toLowerCase().contains(s) || (op.source ?? '').toLowerCase().contains(s) || (op.destination ?? '').toLowerCase().contains(s);
      }
      return true;
    }).toList();

    list.sort((a, b) {
      int res = 0;
      switch (_sortField) {
  case 'operations_amount': res = a.amount.compareTo(b.amount); break;
  case 'operations_name': res = a.label.compareTo(b.label); break;
  case 'operations_date': res = a.levyDate.compareTo(b.levyDate); break;
  case 'operations_id': res = a.id.compareTo(b.id); break;
  default: res = a.levyDate.compareTo(b.levyDate);
      }
      return _sortAsc ? res : -res;
    });

    return list;
  }

  

  void _openDetail(Operation op) async {
    final result = await showDialog<String>(context: context, builder: (_) => OperationDetailDialog(operation: op));
    if (result == 'deleted' || result == 'updated') await _fetchOperations();
  }


  @override
  Widget build(BuildContext context) {
  final ops = _filteredOperations;
  final categories = ['Tous'] + _operations.map((e) => e.category).toSet().toList();
  final theme = Theme.of(context);

    return AppScaffold(
      currentIndex: 0,
  onProfilePressed: (ctx) => Navigator.of(ctx).pushNamed(AppRoutes.profile).then((_) => _init()),
  floatingActionButton: AddOperationFab(onOperationCreated: (op) => setState(()=> _operations.insert(0, op)), operations: _operations),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          // show error if present
          if (_error != null) Padding(padding: const EdgeInsets.only(bottom:8.0), child: Text(_error!, style: const TextStyle(color: Colors.red))),

          // Chart area
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Control aligned top-left of the Card (only the dropdown, no label)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      // use card color from theme for better integration with light/dark modes
                      color: theme.cardColor.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: theme.brightness == Brightness.light ? Colors.black12 : Colors.black26,
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
                          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: theme.textTheme.bodyMedium)))
                          .toList(),
                      onChanged: (v) => setState(() => _chartType = v!),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Chart area below the control
                  SizedBox(
                    height: 220,
                    child: OperationsChart(operations: ops, chartType: _chartType),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Controls (search and manual add button removed)
          Row(children: [
            DropdownButton<String>(value: _categoryFilter, items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _categoryFilter = v!)),
            const SizedBox(width: 12),
            const Spacer(),
            ElevatedButton(onPressed: () => setState(() => _tableView = !_tableView), child: Text(_tableView ? 'Vue calendrier' : 'Vue tableau'))
          ]),

          const SizedBox(height: 12),

          // content
          // The table view adapts its height to the number of rows (up to a max),
          // to avoid overlapping elements below when inside a scroll view.
          _tableView ? _buildTableView(ops) : SizedBox(
            height: MediaQuery.of(context).size.height * 0.56,
            child: CalendarPage(operations: ops, onOperationTap: (op) => _openDetail(op)),
          ),

          // pagination removed: we only show the 15 latest operations
        ]),
        ),
      ),
    );
  }

  

  

  Widget _buildTableView(List<Operation> ops) {
  // No pagination: show only the 15 most recent operations
  final pageItems = ops.take(15).toList();
    // Allow the Card to size itself vertically so the page (outer SingleChildScrollView)
    // becomes scrollable. Keep horizontal scrolling for wide tables. Add a small
    // bottom margin so the card doesn't touch the screen edge.
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        child: SingleChildScrollView(
          // horizontal scrolling for wide tables
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Nom')),
              DataColumn(label: Text('Montant'), numeric: true),
              DataColumn(label: Text('Validé')),
            ],
            rows: pageItems.map((o) => DataRow(cells: [
              DataCell(Text(DateFormat('yyyy-MM-dd').format(o.levyDate)), onTap: () => _openDetail(o)),
              DataCell(Text(o.label), onTap: () => _openDetail(o)),
              DataCell(Text(o.amount.toStringAsFixed(2)), onTap: () => _openDetail(o)),
              DataCell(Icon(o.isValidate ? Icons.check_circle : Icons.remove_circle), onTap: () => _openDetail(o)),
            ])).toList(),
          ), // DataTable inside horizontal SingleChildScrollView
        ), // horizontal SingleChildScrollView
      ), // Card with bottom padding
    );
  }
}
