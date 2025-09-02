import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'config.dart';
import 'models/operation.dart';
import 'services/api_service.dart';
import 'widgets/operations_chart.dart';
import 'pages/calendar_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EconorisApp());
}

class EconorisApp extends StatelessWidget {
  const EconorisApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Config.appName,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const RootRouter(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RootRouter extends StatefulWidget {
  const RootRouter({super.key});
  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter> {
  Future<Map<String, dynamic>> _loadLocal() async {
    final sp = await SharedPreferences.getInstance();
    final jwt = sp.getString('jwt');
    final email = sp.getString('email');
    final name = sp.getString('name');
    return {'jwt': jwt, 'email': email, 'name': name};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(future: _loadLocal(), builder: (context, snap) {
      if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      final data = snap.data!;
      if (data['jwt'] != null && data['jwt'].toString().isNotEmpty) return const HomePage();
      if ((data['email'] ?? '').toString().isNotEmpty && (data['name'] ?? '').toString().isNotEmpty) {
        // request login code then go to code entry
        ApiService.requestLoginCode(data['email'], data['name']);
        return CodeEntryPage(email: data['email'], name: data['name']);
      }
      return const LoginPage();
    });
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailC = TextEditingController();
  final _nameC = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    final email = _emailC.text.trim();
    final name = _nameC.text.trim();
    final sp = await SharedPreferences.getInstance();
    await sp.setString('email', email);
    await sp.setString('name', name);

    final resp = await ApiService.requestLoginCode(email, name);
    setState(() { _loading = false; });
    if (resp.statusCode == 200) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => CodeEntryPage(email: email, name: name)));
    } else {
      String msg = 'Erreur';
      try { final j = jsonDecode(resp.body); msg = j['error'] ?? resp.body; } catch (e) {}
      setState(() { _error = msg; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      body: Center(
        child: Container(
          width: isWide ? 500 : double.infinity,
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [Image.asset('assets/econoris_logo.png', width: 48, height: 48), const SizedBox(width: 8), const Text(Config.appName, style: TextStyle(fontSize: 22))]),
                const SizedBox(height: 12),
                TextField(controller: _emailC, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 8),
                TextField(controller: _nameC, decoration: const InputDecoration(labelText: 'Nom')),
                const SizedBox(height: 12),
                if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _loading ? null : _submit, child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Se connecter'))
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class CodeEntryPage extends StatefulWidget {
  final String email;
  final String name;
  const CodeEntryPage({super.key, required this.email, required this.name});
  @override
  State<CodeEntryPage> createState() => _CodeEntryPageState();
}

class _CodeEntryPageState extends State<CodeEntryPage> {
  final _codeC = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    final code = _codeC.text.trim();
    final resp = await ApiService.confirmLoginCode(widget.email, code);
    setState(() { _loading = false; });
    if (resp.statusCode == 200) {
      try {
        final j = jsonDecode(resp.body);
        final jwt = j['jwt'];
        if (jwt != null) {
          final sp = await SharedPreferences.getInstance();
          await sp.setString('jwt', jwt);
          await sp.setString('email', widget.email);
          await sp.setString('name', widget.name);
          if (!mounted) return;
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
          return;
        }
      } catch (e) {}
      setState(() { _error = 'Réponse invalide du serveur'; });
    } else {
      String msg = 'Erreur';
      try { final j = jsonDecode(resp.body); msg = j['error'] ?? resp.body; } catch (e) {}
      setState(() { _error = msg; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérification')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 400,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Un code à 6 chiffres a été envoyé à ${widget.email}'),
                const SizedBox(height: 8),
                TextField(controller: _codeC, decoration: const InputDecoration(labelText: 'Code (6 chiffres)')),
                if (_error != null) Padding(padding: const EdgeInsets.only(top:8.0), child: Text(_error!, style: const TextStyle(color: Colors.red))),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _loading ? null : _submit, child: const Text('Valider'))
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

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
    if (_jwt == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      final resp = await ApiService.getOperations(_jwt!);

      if (resp.statusCode == 200) {
        final j = jsonDecode(resp.body);
        final rows = j['rows'] as List? ?? [];
        final ops = rows.map((e) => Operation.fromJson(e)).toList();
        ops.sort((a, b) => b.operationsDate.compareTo(a.operationsDate));
        setState(() { _operations = ops; _loading = false; });
      } else {
        String msg = 'Erreur'; try { msg = jsonDecode(resp.body)['error'] ?? resp.body; } catch (e) {}
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

      if (resp.statusCode == 200 || resp.statusCode == 201) {
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

  void _goToProfile() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage())).then((_) => _init());
  }

  @override
  Widget build(BuildContext context) {
    final ops = _filteredOperations;
    final categories = ['Tous'] + _operations.map((e) => e.operationsCategory).toSet().toList();

    return Scaffold(
      appBar: AppBar(title: Row(children: [Image.asset('assets/econoris_logo.png', width: 36), const SizedBox(width: 8), const Text(Config.appName)]), actions: [TextButton(onPressed: _goToProfile, child: const Text('Profil', style: TextStyle(color: Colors.white)))]),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
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
          Expanded(child: _tableView ? _buildTableView(ops) : CalendarPage(operations: ops, onOperationTap: (op) => _openDetail(op))),

          if (_tableView) Padding(padding: const EdgeInsets.only(top:8.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [const Text('Afficher par page:'), const SizedBox(width: 8), DropdownButton<int>(value: _perPage, items: [20,50,100].map((n)=>DropdownMenuItem(value: n, child: Text('$n'))).toList(), onChanged: (v)=> setState(()=>_perPage=v!))]),
            Row(children: [IconButton(onPressed: ()=> setState(()=> _page = (_page-1).clamp(0,999)), icon: const Icon(Icons.chevron_left)), Text('Page ${_page+1}'), IconButton(onPressed: ()=> setState(()=> _page = _page+1), icon: const Icon(Icons.chevron_right))])
          ]))
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(currentIndex: 0, onTap: (i) { if (i==1) Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlaceholderPage(title: 'Prêts'))); if (i==2) Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlaceholderPage(title: 'Horaires'))); }, items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'), BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'Prêts'), BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Horaires')]),
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

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: const Center(child: Text('Page en construction')));
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _jwt;
  String? _email;
  String? _name;
  bool _loading = true;
  final _nameC = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    _jwt = sp.getString('jwt');
    _email = sp.getString('email');
    _name = sp.getString('name');
    _nameC.text = _name ?? '';
    if (_jwt != null) {
      final resp = await ApiService.getProfile(_jwt!);
      if (resp.statusCode == 200) {
        try { final j = jsonDecode(resp.body); setState((){ _email = j['email'] ?? _email; _name = j['name'] ?? _name; _nameC.text = _name ?? ''; _loading = false; }); } catch (e) { setState(()=> _loading = false); }
      } else {
        setState(()=> _loading = false);
      }
    } else {
      setState(()=> _loading = false);
    }
  }

  Future<void> _logout() async {
    if (_jwt != null) await ApiService.logout(_jwt!);
    final sp = await SharedPreferences.getInstance();
    await sp.remove('jwt');
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
  }

  Future<void> _deleteAccount() async {
    if (_jwt == null) return;
    await ApiService.deleteUser(_jwt!);
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
  }

  Future<void> _updateName() async {
    if (_jwt == null) return;
    final newName = _nameC.text.trim();
    final resp = await ApiService.updateUser(_jwt!, _email ?? '', newName);
    if (resp.statusCode == 200) {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('name', newName);
      setState(()=> _name = newName);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nom mis à jour')));
    } else {
      String m = 'Erreur'; try { m = jsonDecode(resp.body)['error'] ?? resp.body; } catch (e) {}
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Profil')), body: _loading ? const Center(child: CircularProgressIndicator()) : Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      ListTile(title: const Text('Email'), subtitle: Text(_email ?? '')),
      TextField(controller: _nameC, decoration: const InputDecoration(labelText: 'Nom')),
      const SizedBox(height: 12),
      Row(children: [ElevatedButton(onPressed: _updateName, child: const Text('Enregistrer')), const SizedBox(width: 12), OutlinedButton(onPressed: _logout, child: const Text('Déconnexion')), const SizedBox(width: 12), TextButton(onPressed: _deleteAccount, child: const Text('Supprimer mon compte', style: TextStyle(color: Colors.red)))],)
    ])));
  }
}

class OperationDetailDialog extends StatelessWidget {
  final Operation operation;
  const OperationDetailDialog({super.key, required this.operation});

  Future<void> _delete(BuildContext context, String? jwt) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Confirmer'), content: const Text('Supprimer cette opération ?'), actions: [TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('Non')), TextButton(onPressed: ()=>Navigator.pop(context,true), child: const Text('Oui'))]));
    if (ok == true && jwt != null) {
      final resp = await ApiService.deleteOperation(jwt, operation.operationsId);
      if (resp.statusCode == 200) {
        Navigator.of(context).pop('deleted');
      } else { String m='Erreur'; try{ m=jsonDecode(resp.body)['error'] ?? resp.body;}catch(e){} ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m))); }
    }
  }

  Future<void> _edit(BuildContext context) async {
    final edited = await showDialog<Operation>(context: context, builder: (_) => OperationEditDialog(operation: operation));
    if (edited != null) {
      final sp = await SharedPreferences.getInstance();
      final jwt = sp.getString('jwt');
      if (jwt != null) {
        final resp = await ApiService.updateOperation(jwt, operation.operationsId, edited.toJson());
        if (resp.statusCode == 200) {
          Navigator.of(context).pop('updated');
        } else { String m='Erreur'; try{ m=jsonDecode(resp.body)['error'] ?? resp.body;}catch(e){} ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m))); }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(future: SharedPreferences.getInstance(), builder: (c,s){ final jwt = s.hasData ? s.data!.getString('jwt') : null;
      return AlertDialog(title: Text(operation.operationsName), content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Date: ${operation.operationsDate.toIso8601String()}'), Text('Montant: ${operation.operationsAmount}'), Text('Source: ${operation.operationsSource}'), Text('Destination: ${operation.operationsDestination}'), Text('Coûts: ${operation.operationsCosts}'), Text('Catégorie: ${operation.operationsCategory}'), Text('Validée: ${operation.operationsValidated}')],)), actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Fermer')), TextButton(onPressed: ()=> _edit(context), child: const Text('Modifier')), TextButton(onPressed: ()=> _delete(context,jwt), child: const Text('Supprimer', style: TextStyle(color: Colors.red))) ]);
    });
  }
}

class OperationEditDialog extends StatefulWidget {
  final Operation? operation;
  const OperationEditDialog({super.key, this.operation});
  @override
  State<OperationEditDialog> createState() => _OperationEditDialogState();
}

class _OperationEditDialogState extends State<OperationEditDialog> {
  final _nameC = TextEditingController();
  final _amountC = TextEditingController();
  final _sourceC = TextEditingController();
  final _destC = TextEditingController();
  final _costsC = TextEditingController();
  final _categoryC = TextEditingController();
  DateTime _date = DateTime.now();
  bool _validated = false;

  @override
  void initState(){ super.initState(); if (widget.operation!=null) { final o = widget.operation!; _nameC.text = o.operationsName; _amountC.text = o.operationsAmount.toString(); _sourceC.text = o.operationsSource; _destC.text = o.operationsDestination; _costsC.text = o.operationsCosts.toString(); _categoryC.text = o.operationsCategory; _date = o.operationsDate; _validated = o.operationsValidated; }}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(title: Text(widget.operation==null ? 'Ajouter opération' : 'Modifier opération'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: _nameC, decoration: const InputDecoration(labelText: 'Nom')), TextField(controller: _amountC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Montant')), TextField(controller: _sourceC, decoration: const InputDecoration(labelText: 'Source')), TextField(controller: _destC, decoration: const InputDecoration(labelText: 'Destination')), TextField(controller: _costsC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Coûts')), TextField(controller: _categoryC, decoration: const InputDecoration(labelText: 'Catégorie')), Row(children: [const Text('Date: '), TextButton(onPressed: () async { final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (d!=null) setState(()=>_date=d); }, child: Text('${_date.year}-${_date.month}-${_date.day}'))]), CheckboxListTile(value: _validated, onChanged: (v){ setState(()=>_validated=v!); }, title: const Text('Validée'))])), actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Annuler')), TextButton(onPressed: ()=> _save(), child: const Text('Enregistrer'))]);
  }

  void _save() {
    final op = Operation(operationsId: widget.operation?.operationsId ?? DateTime.now().millisecondsSinceEpoch, operationsDate: _date, operationsName: _nameC.text, operationsAmount: double.tryParse(_amountC.text) ?? 0, operationsSource: _sourceC.text, operationsDestination: _destC.text, operationsCosts: double.tryParse(_costsC.text) ?? 0, operationsCategory: _categoryC.text, operationsValidated: _validated, operationsRedundancy: '', operationsCreatedAt: DateTime.now());
    Navigator.of(context).pop(op);
  }
}