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
  int _perPage = 20;
  int _page = 0;

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
        final j = jsonDecode(resp.body);
        final rows = j['rows'] as List? ?? [];
        final ops = rows.map((e) => Operation.fromJson(e)).toList();
        ops.sort((a, b) => b.operationsDate.compareTo(a.operationsDate));
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
      if (_categoryFilter != 'Tous' && op.operationsCategory != _categoryFilter) return false;
      if (_search.isNotEmpty) {
        final s = _search.toLowerCase();
        return op.operationsName.toLowerCase().contains(s) || op.operationsSource.toLowerCase().contains(s) || op.operationsDestination.toLowerCase().contains(s);
      }
      return true;
    }).toList();

    list.sort((a, b) {
      int res = 0;
      switch (_sortField) {
        case 'operations_amount': res = a.operationsAmount.compareTo(b.operationsAmount); break;
        case 'operations_name': res = a.operationsName.compareTo(b.operationsName); break;
        case 'operations_date': res = a.operationsDate.compareTo(b.operationsDate); break;
        case 'operations_id': res = a.operationsId.compareTo(b.operationsId); break;
        default: res = a.operationsDate.compareTo(b.operationsDate);
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
          final created = Operation.fromJson(jsonDecode(resp.body));
          setState(() { _operations.insert(0, created); });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opération ajoutée')));
        } catch (e) {
          await _fetchOperations();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opération ajoutée')));
        }
      } else {
        String m = 'Erreur'; try { m = jsonDecode(resp.body)['error'] ?? resp.body; } catch (e) {}
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
    final categories = ['Tous'] + _operations.map((e) => e.operationsCategory).toSet().toList();

    return AppScaffold(
      currentIndex: 0,
  onProfilePressed: (ctx) => Navigator.of(ctx).pushNamed(AppRoutes.profile).then((_) => _init()),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          // show error if present
          if (_error != null) Padding(padding: const EdgeInsets.only(bottom:8.0), child: Text(_error!, style: const TextStyle(color: Colors.red))),

          // Chart area
          Card(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
            Expanded(child: SizedBox(height: 220, child: OperationsChart(operations: ops, chartType: _chartType))),
            Column(children: [
              const Text('Type de graphique'),
              const SizedBox(height: 8),
              DropdownButton<String>(value: _chartType, items: ['line','bar','pie'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() => _chartType = v!))
            ])
          ]))),

          const SizedBox(height: 12),

          // Controls
          Row(children: [
            DropdownButton<String>(value: _categoryFilter, items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _categoryFilter = v!)),
            const SizedBox(width: 12),
            Expanded(child: TextField(decoration: const InputDecoration(hintText: 'Rechercher'), onChanged: (v) => setState(() => _search = v))),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: _openAddModal, child: const Text('Ajouter une opération')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: _fetchOperations, child: const Text('Rafraîchir')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () => setState(() => _tableView = !_tableView), child: Text(_tableView ? 'Vue calendrier' : 'Vue tableau'))
          ]),

          const SizedBox(height: 12),

          // content
          // Give the table/calendar a bounded height when inside a vertical scroll view
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.56,
            child: _tableView ? _buildTableView(ops) : CalendarPage(operations: ops, onOperationTap: (op) => _openDetail(op)),
          ),

          if (_tableView) Padding(padding: const EdgeInsets.only(top:8.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [const Text('Afficher par page:'), const SizedBox(width: 8), DropdownButton<int>(value: _perPage, items: [20,50,100].map((n)=>DropdownMenuItem(value: n, child: Text('$n'))).toList(), onChanged: (v)=> setState(()=>_perPage=v!))]),
            Row(children: [IconButton(onPressed: ()=> setState(()=> _page = (_page-1).clamp(0,999)), icon: const Icon(Icons.chevron_left)), Text('Page ${_page+1}'), IconButton(onPressed: ()=> setState(()=> _page = _page+1), icon: const Icon(Icons.chevron_right))])
          ]))
        ]),
        ),
      ),
    );
  }

  Widget _buildTableView(List<Operation> ops) {
    final start = _page * _perPage;
    final pageItems = ops.skip(start).take(_perPage).toList();
    return Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columns: const [
      DataColumn(label: Text('Date')),
      DataColumn(label: Text('Nom')),
      DataColumn(label: Text('Montant'), numeric: true),
      DataColumn(label: Text('Source')),
      DataColumn(label: Text('Destination')),
      DataColumn(label: Text('Catégorie')),
      DataColumn(label: Text('Validé')),
    ], rows: pageItems.map((o) => DataRow(cells: [
      DataCell(Text(DateFormat('yyyy-MM-dd').format(o.date)), onTap: () => _openDetail(o)),
      DataCell(Text(o.name), onTap: () => _openDetail(o)),
      DataCell(Text(o.amount.toStringAsFixed(2)), onTap: () => _openDetail(o)),
      DataCell(Text(o.operationsSource), onTap: () => _openDetail(o)),
      DataCell(Text(o.operationsDestination), onTap: () => _openDetail(o)),
      DataCell(Text(o.category), onTap: () => _openDetail(o)),
      DataCell(Icon(o.operationsValidated ? Icons.check_circle : Icons.remove_circle), onTap: () => _openDetail(o)),
    ])).toList())));
  }
}
