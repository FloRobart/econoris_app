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
  // FAB open state for the three small bubbles
  bool _fabOpen = false;

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

  void _openAddModal() async {
    final res = await showDialog<Operation>(context: context, builder: (_) => const OperationEditDialog());
    if (res != null && _jwt != null) {
      final body = res.toJson();
      final resp = await ApiService.addOperation(_jwt!, body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
        try {
          // Parse body robustly: server may wrap the created operation in
          // {"operation": {...}} or {"rows": [...]}, or return it directly.
          final parsed = jsonDecode(resp.body);
          Map<String, dynamic>? opJson;
          if (parsed is Map<String, dynamic>) {
            if (parsed.containsKey('operation') && parsed['operation'] is Map) {
              opJson = Map<String, dynamic>.from(parsed['operation']);
            } else if (parsed.containsKey('rows') && parsed['rows'] is List && (parsed['rows'] as List).isNotEmpty && (parsed['rows'][0] is Map)) {
              opJson = Map<String, dynamic>.from(parsed['rows'][0]);
            } else if (parsed.containsKey('data') && parsed['data'] is Map) {
              opJson = Map<String, dynamic>.from(parsed['data']);
            } else {
              // Maybe the response is already the operation map
              opJson = Map<String, dynamic>.from(parsed);
            }
          } else if (parsed is List && parsed.isNotEmpty && parsed[0] is Map) {
            opJson = Map<String, dynamic>.from(parsed[0]);
          }

          if (opJson != null) {
            final created = Operation.fromJson(opJson);
            setState(() { _operations.insert(0, created); });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opération ajoutée')));
          } else {
            // fallback: refresh full list
            await _fetchOperations();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opération ajoutée')));
          }
        } catch (e) {
          await _fetchOperations();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opération ajoutée')));
        }
      } else {
        String m = 'Erreur'; try { final p = jsonDecode(resp.body); if (p is Map && p.containsKey('error')) m = p['error'].toString(); else m = resp.body; } catch (e) {}
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
      }
    }
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
      // Custom speed-dial: main FAB + 3 small bubbles that appear when opened
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // small bubble: Revenu
          AnimatedSlide(
            offset: _fabOpen ? const Offset(0, 0) : const Offset(0, 0.2),
            duration: const Duration(milliseconds: 200),
            child: AnimatedOpacity(
              opacity: _fabOpen ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  onTap: () { setState(()=> _fabOpen = false); _openAddModalWithMode('revenue'); },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Material(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(24),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () { setState(()=> _fabOpen = false); _openAddModalWithMode('revenue'); },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.arrow_downward, size: 18, color: Colors.black), SizedBox(width: 8), Text('Revenu', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // small bubble: Dépense
          AnimatedSlide(
            offset: _fabOpen ? const Offset(0, 0) : const Offset(0, 0.2),
            duration: const Duration(milliseconds: 220),
            child: AnimatedOpacity(
              opacity: _fabOpen ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 220),
                child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  onTap: () { setState(()=> _fabOpen = false); _openAddModalWithMode('depense'); },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Material(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(24),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () { setState(()=> _fabOpen = false); _openAddModalWithMode('depense'); },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.arrow_upward, size: 18, color: Colors.black), SizedBox(width: 8), Text('Dépense', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // small bubble: Abonnement
          AnimatedSlide(
            offset: _fabOpen ? const Offset(0, 0) : const Offset(0, 0.2),
            duration: const Duration(milliseconds: 240),
            child: AnimatedOpacity(
              opacity: _fabOpen ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 240),
                child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  onTap: () { setState(()=> _fabOpen = false); _openAddModalWithMode('abonnement'); },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Material(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(24),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () { setState(()=> _fabOpen = false); _openAddModalWithMode('abonnement'); },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.repeat, size: 18, color: Colors.black), SizedBox(width: 8), Text('Abonnement', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // main FAB
          FloatingActionButton(
            onPressed: () => setState(() => _fabOpen = !_fabOpen),
            child: AnimatedRotation(
              turns: _fabOpen ? 0.125 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
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

          // Controls
          Row(children: [
            DropdownButton<String>(value: _categoryFilter, items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _categoryFilter = v!)),
            const SizedBox(width: 12),
            Expanded(child: TextField(decoration: const InputDecoration(hintText: 'Rechercher'), onChanged: (v) => setState(() => _search = v))),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: _openAddModal, child: const Text('Ajouter une opération')),
            const SizedBox(width: 8),
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

  

  void _openAddModalWithMode(String mode) async {
    final res = await showDialog<Operation>(context: context, builder: (_) => OperationEditDialog(mode: mode));
    if (res != null && _jwt != null) {
      final body = res.toJson();
      final resp = await ApiService.addOperation(_jwt!, body);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        try {
          final parsed = jsonDecode(resp.body);
          Map<String, dynamic>? opJson;
          if (parsed is Map<String, dynamic>) {
            if (parsed.containsKey('operation') && parsed['operation'] is Map) {
              opJson = Map<String, dynamic>.from(parsed['operation']);
            } else if (parsed.containsKey('rows') && parsed['rows'] is List && (parsed['rows'] as List).isNotEmpty && (parsed['rows'][0] is Map)) {
              opJson = Map<String, dynamic>.from(parsed['rows'][0]);
            } else if (parsed.containsKey('data') && parsed['data'] is Map) {
              opJson = Map<String, dynamic>.from(parsed['data']);
            } else {
              opJson = Map<String, dynamic>.from(parsed);
            }
          } else if (parsed is List && parsed.isNotEmpty && parsed[0] is Map) {
            opJson = Map<String, dynamic>.from(parsed[0]);
          }

          if (opJson != null) {
            final created = Operation.fromJson(opJson);
            setState(() { _operations.insert(0, created); });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opération ajoutée')));
          } else {
            await _fetchOperations();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opération ajoutée')));
          }
        } catch (e) {
          await _fetchOperations();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opération ajoutée')));
        }
      } else {
        String m = 'Erreur'; try { final p = jsonDecode(resp.body); if (p is Map && p.containsKey('error')) m = p['error'].toString(); else m = resp.body; } catch (e) {}
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
      }
    }
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
