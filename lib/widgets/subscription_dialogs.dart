import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';
import '../services/api_service.dart';

class SubscriptionDetailDialog extends StatefulWidget {
  final Subscription subscription;
  const SubscriptionDetailDialog({super.key, required this.subscription});

  @override
  State<SubscriptionDetailDialog> createState() => _SubscriptionDetailDialogState();
}

class _SubscriptionDetailDialogState extends State<SubscriptionDetailDialog> {
  Future<void> _delete() async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Confirmer'), content: const Text('Supprimer cet abonnement ?'), actions: [TextButton(onPressed: ()=>Navigator.pop(c,false), child: const Text('Non')), TextButton(onPressed: ()=>Navigator.pop(c,true), child: const Text('Oui'))]));
    if (ok != true) return;
    final sp = await SharedPreferences.getInstance();
    final jwt = sp.getString('jwt');
    if (jwt == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Non authentifié')));
      return;
    }
    final resp = await ApiService.deleteSubscription(jwt, widget.subscription.id);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (!mounted) return;
      Navigator.of(context).pop('deleted');
    } else {
      String m = 'Erreur';
      try {
        final p = jsonDecode(resp.body);
        if (p is Map && p.containsKey('error')) m = p['error'].toString();
      } catch (_) {}
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.subscription;
    return AlertDialog(
      title: Text(s.label),
      content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Montant: ${s.amount}'),
        Text('Catégorie: ${s.category}'),
        Text('Début: ${s.startDate.toIso8601String()}'),
        Text('Fin: ${s.endDate?.toIso8601String() ?? '-'}'),
        Text('Fréquence: ${s.intervalValue} ${s.intervalUnit}'),
        Text('Actif: ${s.active}'),
      ])),
      actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Fermer')), TextButton(onPressed: _delete, child: const Text('Supprimer', style: TextStyle(color: Colors.red)))],
    );
  }
}

class SubscriptionCreateDialog extends StatefulWidget {
  const SubscriptionCreateDialog({super.key});
  @override
  State<SubscriptionCreateDialog> createState() => _SubscriptionCreateDialogState();
}

class _SubscriptionCreateDialogState extends State<SubscriptionCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelC = TextEditingController();
  final _amountC = TextEditingController();
  final _categoryC = TextEditingController();
  DateTime _start = DateTime.now();
  bool _active = true;
  int _intervalValue = 1;
  String _intervalUnit = 'months';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un abonnement'),
      content: SingleChildScrollView(child: Form(key: _formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: _labelC, decoration: const InputDecoration(labelText: 'Nom *'), validator: (v){ if (v==null||v.trim().isEmpty) return 'Nom requis'; return null; }),
        TextFormField(controller: _amountC, keyboardType: const TextInputType.numberWithOptions(decimal:true), decoration: const InputDecoration(labelText: 'Montant *'), validator: (v){ if (v==null||v.trim().isEmpty) return 'Montant requis'; if (double.tryParse(v.replaceAll(',','.'))==null) return 'Montant invalide'; return null; }),
        TextFormField(controller: _categoryC, decoration: const InputDecoration(labelText: 'Catégorie')),
        Row(children: [const Text('Début: '), TextButton(onPressed: () async { final d = await showDatePicker(context: context, initialDate: _start, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (d!=null) setState(()=>_start=d); }, child: Text('${_start.year}-${_start.month}-${_start.day}'))]),
        Row(children: [const Text('Intervalle: '), const SizedBox(width:8), SizedBox(width:60, child: TextFormField(initialValue: '1', keyboardType: TextInputType.number, onChanged: (v)=> _intervalValue = int.tryParse(v) ?? 1)), const SizedBox(width:8), DropdownButton<String>(value: _intervalUnit, items: const [DropdownMenuItem(value: 'days', child: Text('jours')), DropdownMenuItem(value: 'weeks', child: Text('semaines')), DropdownMenuItem(value: 'months', child: Text('mois'))], onChanged: (v){ if (v!=null) setState(()=>_intervalUnit=v); })]),
        CheckboxListTile(value: _active, onChanged: (v)=> setState(()=>_active=v!), title: const Text('Actif')),
      ]))),
      actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Annuler')), TextButton(onPressed: ()=> _save(), child: const Text('Créer'))],
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final parsedAmount = double.tryParse(_amountC.text.replaceAll(',', '.')) ?? 0.0;
    final s = Subscription(
      id: DateTime.now().millisecondsSinceEpoch,
      label: _labelC.text,
      amount: parsedAmount,
      category: _categoryC.text,
      source: null,
      destination: null,
      costs: 0.0,
      active: _active,
      intervalValue: _intervalValue,
      intervalUnit: _intervalUnit,
      startDate: _start,
      endDate: null,
      dayOfMonth: null,
      lastGeneratedAt: null,
      userId: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    Navigator.of(context).pop(s);
  }
}
