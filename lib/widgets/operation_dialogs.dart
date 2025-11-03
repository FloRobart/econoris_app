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
  final resp = await ApiService.deleteOperation(jwt, operation.id);
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
  final resp = await ApiService.updateOperation(jwt, edited.id, edited.toJson());
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
          title: Text(operation.label),
          content: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Date: ${operation.levyDate.toIso8601String()}'),
              Text('Montant: ${operation.amount}'),
              Text('Source: ${operation.source ?? ''}'),
              Text('Destination: ${operation.destination ?? ''}'),
              Text('Coûts: ${operation.costs}'),
              Text('Catégorie: ${operation.category}'),
              Text('Validée: ${operation.isValidate}')
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
  /// mode can be 'revenue', 'depense' or 'abonnement'. If null the dialog
  /// behaves normally.
  final String? mode;
  const OperationEditDialog({super.key, this.operation, this.mode});
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
  // subscription fields (only used in UI for 'abonnement' mode)
  String _frequency = 'mensuel';
  int? _customFreqCount;
  String? _customFreqUnit; // 'jours', 'semaines', 'mois'

  @override
  void initState(){
    super.initState();
    if (widget.operation!=null) {
  final o = widget.operation!;
  _nameC.text = o.label;
  _amountC.text = o.amount.toString();
  _sourceC.text = o.source ?? '';
  _destC.text = o.destination ?? '';
  _costsC.text = o.costs.toString();
  _categoryC.text = o.category;
  _date = o.levyDate;
  _validated = o.isValidate;
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
            if (widget.mode != null) Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(bottom:8.0), child: Text(_modeLabel(), style: const TextStyle(fontWeight: FontWeight.w600)))),
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
            // For 'abonnement' show frequency selector
            if (widget.mode == 'abonnement') Padding(
              padding: const EdgeInsets.only(top:8.0),
              child: Row(children: [
                const Text('Fréquence: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _frequency,
                  items: const [
                    DropdownMenuItem(value: 'mensuel', child: Text('Mensuel')),
                    DropdownMenuItem(value: 'trimestriel', child: Text('Trimestriel')),
                    DropdownMenuItem(value: 'semestriel', child: Text('Semestriel')),
                    DropdownMenuItem(value: 'annuel', child: Text('Annuel')),
                    DropdownMenuItem(value: 'custom', child: Text('Custom')),
                  ],
                  onChanged: (v) async {
                    if (v == null) return;
                    if (v != 'custom') {
                      setState(() => _frequency = v);
                      return;
                    }
                    // custom selected -> show popup to get X and UNIT
                    final result = await showDialog<Map<String, dynamic>>(context: context, builder: (_) => AlertDialog(
                      title: const Text('Custom'),
                      content: Column(mainAxisSize: MainAxisSize.min, children: [
                        TextFormField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'X (entier)'), onChanged: (s){}),
                        // We'll implement inputs inline below via stateful builder
                      ]),
                      actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Annuler'))],
                    ));
                    // For simplicity show a simple two-step dialog instead
                    if (result == null) {
                      // open a custom input flow
                      final custom = await showDialog<Map<String,dynamic>>(context: context, builder: (c) {
                        int count = 1;
                        String unit = 'jours';
                        return AlertDialog(
                          title: const Text('Paiement custom'),
                          content: StatefulBuilder(builder: (ctx, setSt) => Column(mainAxisSize: MainAxisSize.min, children: [
                            TextFormField(initialValue: '1', keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'X (entier)'), onChanged: (v) { count = int.tryParse(v) ?? 1; }),
                            const SizedBox(height:8),
                            DropdownButton<String>(value: unit, items: const [DropdownMenuItem(value: 'jours', child: Text('Jours')), DropdownMenuItem(value: 'semaines', child: Text('Semaines')), DropdownMenuItem(value: 'mois', child: Text('Mois'))], onChanged: (u){ if (u!=null) setSt(()=>unit=u); }),
                          ])),
                          actions: [TextButton(onPressed: ()=> Navigator.pop(c), child: const Text('Annuler')), TextButton(onPressed: ()=> Navigator.pop(c, {'count':count,'unit':unit}), child: const Text('OK'))],
                        );
                      });
                      if (custom != null) setState(() { _frequency = 'custom'; _customFreqCount = custom['count'] as int?; _customFreqUnit = custom['unit'] as String?; });
                    }
                  },
                ),
                if (_frequency == 'custom' && _customFreqCount != null && _customFreqUnit != null) Padding(padding: const EdgeInsets.only(left:12.0), child: Text('Paiement tous les ${_customFreqCount} ${_customFreqUnit}'))
              ]),
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
              // costs should not appear for revenue mode
              if (widget.mode != 'revenue') TextFormField(controller: _costsC, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Coûts')),
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
    double finalAmount = parsedAmount;
    if (widget.mode == 'revenue') finalAmount = parsedAmount.abs();
    else if (widget.mode == 'depense') finalAmount = -parsedAmount.abs();

    final parsedCostsForSave = widget.mode == 'revenue' ? 0.0 : parsedCosts;

    final op = Operation(
      id: widget.operation?.id ?? DateTime.now().millisecondsSinceEpoch,
      levyDate: _date,
      label: _nameC.text,
      amount: finalAmount,
      category: _categoryC.text,

      source: _sourceC.text.isEmpty ? null : _sourceC.text,
      destination: _destC.text.isEmpty ? null : _destC.text,
      costs: parsedCostsForSave,
      isValidate: _validated,

      userId: widget.operation?.userId ?? 0,
      subscriptionId: widget.operation?.subscriptionId,
      createdAt: widget.operation?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    Navigator.of(context).pop(op);
  }

  String _modeLabel(){
    switch(widget.mode){
      case 'revenue': return 'Type: Revenu (montant forcé positif)';
      case 'depense': return 'Type: Dépense (montant forcé négatif)';
      case 'abonnement': return 'Type: Abonnement';
    }
    return '';
  }
}
