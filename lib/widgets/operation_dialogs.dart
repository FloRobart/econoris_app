import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/operation.dart';
import '../services/api_service.dart';

class OperationDetailDialog extends StatelessWidget {
  final Operation operation;
  const OperationDetailDialog({super.key, required this.operation});

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Confirmer'), content: const Text('Supprimer cette opération ?'), actions: [TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('Non')), TextButton(onPressed: ()=>Navigator.pop(context,true), child: const Text('Oui'))]));
    if (ok == true) {
      final sp = await SharedPreferences.getInstance();
      final jwt = sp.getString('jwt');
      if (jwt == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Non authentifié')));
        return;
      }
      final resp = await ApiService.deleteOperation(jwt, operation.operationsId);
  if (resp.statusCode >= 200 && resp.statusCode < 300) {
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
        final resp = await ApiService.updateOperation(jwt, edited.toJson());
  if (resp.statusCode >= 200 && resp.statusCode < 300) Navigator.of(context).pop('updated');
        else { String m='Erreur'; try{ m=jsonDecode(resp.body)['error'] ?? resp.body;}catch(e){}; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m))); }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (c, s) {
        return AlertDialog(
          title: Text(operation.operationsName),
          content: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Date: ${operation.operationsDate.toIso8601String()}'),
              Text('Montant: ${operation.operationsAmount}'),
              Text('Source: ${operation.operationsSource}'),
              Text('Destination: ${operation.operationsDestination}'),
              Text('Coûts: ${operation.operationsCosts}'),
              Text('Catégorie: ${operation.operationsCategory}'),
              Text('Validée: ${operation.operationsValidated}')
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
            TextButton(onPressed: () => _edit(context), child: const Text('Modifier')),
            TextButton(onPressed: () => _delete(context), child: const Text('Supprimer', style: TextStyle(color: Colors.red)))
          ],
        );
      }
    );
  }
}

class OperationEditDialog extends StatefulWidget {
  final Operation? operation;
  const OperationEditDialog({super.key, this.operation});
  @override
  State<OperationEditDialog> createState() => _OperationEditDialogState();
}

class _OperationEditDialogState extends State<OperationEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _amountC = TextEditingController();
  final _sourceC = TextEditingController();
  final _destC = TextEditingController();
  final _costsC = TextEditingController();
  final _categoryC = TextEditingController();
  DateTime _date = DateTime.now();
  bool _validated = true;
  bool _expanded = false;

  @override
  void initState(){
    super.initState();
    if (widget.operation!=null) {
      final o = widget.operation!;
      _nameC.text = o.operationsName;
      _amountC.text = o.operationsAmount.toString();
      _sourceC.text = o.operationsSource;
      _destC.text = o.operationsDestination;
      _costsC.text = o.operationsCosts.toString();
      _categoryC.text = o.operationsCategory;
      _date = o.operationsDate;
      _validated = o.operationsValidated;
    } else {
      // For new operations, default validated to true per requirements
      _validated = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.operation==null ? 'Ajouter une opération' : 'Modifier une opération'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Only show Date, Nom, Montant et Catégorie initially
            Row(children: [
              const Text('Date: ', style: TextStyle(fontSize: 16)),
              TextButton(
                onPressed: () async {
                  final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (d!=null) setState(()=>_date=d);
                },
                child: Text('${_date.year}-${_date.month}-${_date.day}')
              )
            ]),
            TextFormField(
              controller: _nameC,
              decoration: const InputDecoration(labelText: 'Nom *'),
              validator: (v) { if (v == null || v.trim().isEmpty) return 'Nom requis'; return null; },
            ),
            TextFormField(
              controller: _amountC,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Montant *'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Montant requis';
                final parsed = double.tryParse(v.replaceAll(',', '.'));
                if (parsed == null) return 'Montant invalide';
                return null;
              },
            ),
            TextFormField(
              controller: _categoryC,
              decoration: const InputDecoration(labelText: 'Catégorie *'),
              validator: (v) { if (v == null || v.trim().isEmpty) return 'Catégorie requise'; return null; },
            ),

            // Toggle button to show/hide additional fields
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: OutlinedButton(
                  onPressed: () => setState(()=>_expanded = !_expanded),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                  child: Text(_expanded ? 'Afficher moins' : 'Afficher plus'),
                ),
              ),
            ),

            // Hidden fields — still part of the form and will be sent on save
            if (_expanded) ...[
              TextFormField(controller: _sourceC, decoration: const InputDecoration(labelText: 'Source')),
              TextFormField(controller: _destC, decoration: const InputDecoration(labelText: 'Destination')),
              TextFormField(controller: _costsC, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Coûts')),
            ],

            CheckboxListTile(
              value: _validated,
              onChanged: (v){ setState(()=>_validated=v!); },
              title: const Text('Validée')
            ),
          ],
        ),
      ),
    ),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Annuler')),
        TextButton(onPressed: ()=> _save(), child: const Text('Enregistrer'))
      ],
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final parsedAmount = double.tryParse(_amountC.text.replaceAll(',', '.')) ?? 0.0;
    final parsedCosts = double.tryParse(_costsC.text.replaceAll(',', '.')) ?? 0.0;
    final op = Operation(
      operationsId: widget.operation?.operationsId ?? DateTime.now().millisecondsSinceEpoch,
      operationsDate: _date,
      operationsName: _nameC.text,
      operationsAmount: parsedAmount,
      operationsSource: _sourceC.text,
      operationsDestination: _destC.text,
      operationsCosts: parsedCosts,
      operationsCategory: _categoryC.text,
      operationsValidated: _validated,
      operationsRedundancy: '',
      operationsCreatedAt: DateTime.now(),
    );
    Navigator.of(context).pop(op);
  }
}
