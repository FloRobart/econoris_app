import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/services/api/operations_api_client.dart';
import '../../../data/services/global_data.dart';
import '../../../domain/models/operations/operation.dart';
import '../../../domain/models/subscriptions/subscription.dart';

class OperationDetailDialog extends StatefulWidget {
  final Operation operation;
  const OperationDetailDialog({super.key, required this.operation});

  @override
  State<OperationDetailDialog> createState() => _OperationDetailDialogState();
}

class _OperationDetailDialogState extends State<OperationDetailDialog> {
  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Confirmer'),
        content: const Text('Supprimer cette opération ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Oui'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final sp = await SharedPreferences.getInstance();
      final jwt = sp.getString('jwt');
      if (jwt == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Non authentifié')));
        return;
      }

      final resp = await OperationsApiClient.deleteOperation(
        widget.operation.id,
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        // remove from central store so UI updates immediately
        try {
          GlobalData.instance.removeOperationById(widget.operation.id);
        } catch (_) {}
        if (!mounted) return;
        Navigator.of(context).pop('deleted');
      } else {
        String m = 'Erreur';
        try {
          final parsed = jsonDecode(resp.body);
          m = parsed['error'] ?? resp.body;
        } catch (e, st) {
          debugPrint('deleteOperation parse error: $e\n$st');
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
      }
    }
  }

  Future<void> _edit() async {
    final edited = await showDialog<Operation>(
      context: context,
      builder: (_) => OperationEditDialog(operation: widget.operation),
    );
    if (edited != null) {
      final sp = await SharedPreferences.getInstance();
      final jwt = sp.getString('jwt');
      if (jwt != null) {
        final resp = await OperationsApiClient.updateOperation(
          edited.id,
          edited.toJson(),
        );
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          // try to parse returned operation and upsert into central store
          try {
            final parsed = jsonDecode(resp.body);
            Map<String, dynamic>? opJson;
            if (parsed is Map<String, dynamic>) {
              if (parsed.containsKey('operation') &&
                  parsed['operation'] is Map) {
                opJson = Map<String, dynamic>.from(parsed['operation']);
              } else if (parsed.containsKey('data') && parsed['data'] is Map) {
                opJson = Map<String, dynamic>.from(parsed['data']);
              } else if (parsed.containsKey('row') && parsed['row'] is Map) {
                opJson = Map<String, dynamic>.from(parsed['row']);
              } else if (parsed.containsKey('rows') &&
                  parsed['rows'] is List &&
                  (parsed['rows'] as List).isNotEmpty &&
                  (parsed['rows'][0] is Map)) {
                opJson = Map<String, dynamic>.from(parsed['rows'][0]);
              } else if (parsed.containsKey('result') &&
                  parsed['result'] is Map) {
                opJson = Map<String, dynamic>.from(parsed['result']);
              } else {
                opJson = Map<String, dynamic>.from(parsed);
              }
            } else if (parsed is List &&
                parsed.isNotEmpty &&
                parsed[0] is Map) {
              opJson = Map<String, dynamic>.from(parsed[0]);
            }
            if (opJson != null) {
              GlobalData.instance.upsertOperationFromJson(opJson);
            }
          } catch (e, st) {
            debugPrint('updateOperation parse error: $e\n$st');
          }
          if (!mounted) return;
          Navigator.of(context).pop('updated');
        } else {
          String m = 'Erreur';
          try {
            final parsed = jsonDecode(resp.body);
            m = parsed['error'] ?? resp.body;
          } catch (e, st) {
            debugPrint('updateOperation parse error: $e\n$st');
          }
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(m)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (c, s) {
        return AlertDialog(
          title: Text(widget.operation.label),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${widget.operation.levyDate.toIso8601String()}'),
                Text('Montant: ${widget.operation.amount}'),
                Text('Source: ${widget.operation.source ?? ''}'),
                Text('Destination: ${widget.operation.destination ?? ''}'),
                Text('Coûts: ${widget.operation.costs}'),
                Text('Catégorie: ${widget.operation.category}'),
                Text('Validée: ${widget.operation.isValidate}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Fermer'),
            ),
            TextButton(onPressed: _edit, child: const Text('Modifier')),
            TextButton(
              onPressed: _delete,
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class OperationEditDialog extends StatefulWidget {
  final Operation? operation;

  /// Optional subscription to edit. When provided the dialog will be
  /// initialised with the subscription values and will return a
  /// subscription payload when saved.
  final Subscription? subscription;

  /// Optional list of all known operations (used to derive category suggestions).
  final List<Operation>? operations;

  /// Optional list of subscriptions (also used to derive category suggestions).
  final List<Subscription>? subscriptions;

  /// mode can be 'revenue', 'depense' or 'abonnement'. If null the dialog
  /// behaves normally.
  final String? mode;
  const OperationEditDialog({
    super.key,
    this.operation,
    this.subscription,
    this.mode,
    this.operations,
    this.subscriptions,
  });
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
  late TextEditingController _categoryC;
  // initial value to set on the Autocomplete controller when it's created
  String _categoryInitial = '';
  // derived categories from provided operations (preserve first-seen order)
  List<String> _allCategories = [];
  DateTime _date = DateTime.now();
  bool _validated = true;
  bool _expanded = false;
  // recurrence UI
  bool _recurrence = false;
  String _frequency = 'mensuel';
  final TextEditingController _customValueC = TextEditingController();
  String _customUnit = 'mois'; // 'semaine' | 'mois' | 'année'

  @override
  void initState() {
    super.initState();
    if (widget.operation != null) {
      final o = widget.operation!;
      _nameC.text = o.label;
      _amountC.text = o.amount.toString();
      _sourceC.text = o.source ?? '';
      _destC.text = o.destination ?? '';
      _costsC.text = o.costs.toString();
      _categoryInitial = o.category;
      _date = o.levyDate;
      _validated = o.isValidate;
    } else if (widget.subscription != null) {
      // Editing a subscription: prefill values and enable recurrence UI
      final s = widget.subscription!;
      _nameC.text = s.label;
      _amountC.text = s.amount.toString();
      _sourceC.text = s.source ?? '';
      _destC.text = s.destination ?? '';
      _costsC.text = s.costs.toString();
      _categoryInitial = s.category;
      _date = s.startDate;
      _recurrence = true;
      _frequency = 'custom';
      _customValueC.text = s.intervalValue.toString();
      // map api unit token to local unit labels
      if (s.intervalUnit == 'weeks') {
        _customUnit = 'semaine';
      } else if (s.intervalUnit == 'months') {
        _customUnit = 'mois';
      } else if (s.intervalUnit == 'years') {
        _customUnit = 'année';
      } else {
        _customUnit = 'mois';
      }
      _validated = true;
    } else {
      // For new operations, default validated to true per requirements
      _validated = true;
    }
    // If dialog opened in abonnement mode, pre-enable recurrence
    if (widget.mode == 'abonnement') {
      _recurrence = true;
    }
    // derive categories preserving first occurrence order and combining
    // subscriptions and operations lists (subscriptions first)
    final seen = <String>{};
    final list = <String>[];
    if (widget.subscriptions != null) {
      for (final s in widget.subscriptions!) {
        final c = s.category;
        if (c.isNotEmpty && !seen.contains(c)) {
          seen.add(c);
          list.add(c);
        }
      }
    }
    if (widget.operations != null) {
      for (final op in widget.operations!) {
        final c = op.category;
        if (c.isNotEmpty && !seen.contains(c)) {
          seen.add(c);
          list.add(c);
        }
      }
    }
    _allCategories = list;
  }

  @override
  Widget build(BuildContext context) {
    // determine noun/article for dialog title based on mode
    final noun = widget.mode != null ? _modeLabel() : 'opération';
    final article = (widget.mode == 'depense' || widget.mode == null)
        ? 'une'
        : 'un';
    return AlertDialog(
      title: Text(
        widget.operation == null
            ? 'Ajouter $article $noun'
            : 'Modifier $article $noun',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.mode != null)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    // text removed as requested
                    child: SizedBox.shrink(),
                  ),
                ),
              // Only show Date, Nom, Montant et Catégorie initially
              Row(
                children: [
                  const Text('Date: ', style: TextStyle(fontSize: 16)),
                  TextButton(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (d != null) {
                        setState(() => _date = d);
                      }
                    },
                    child: Text('${_date.year}-${_date.month}-${_date.day}'),
                  ),
                ],
              ),
              TextFormField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: 'Nom *'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Nom requis';
                  return null;
                },
              ),
              TextFormField(
                controller: _amountC,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Montant *'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Montant requis';
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null) return 'Montant invalide';
                  return null;
                },
              ),

              // Free-text category field with suggestions.
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  final q = textEditingValue.text;
                  if (_allCategories.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  if (q.trim().isEmpty) return _allCategories;
                  final cleaned = q.toLowerCase().replaceAll(
                    RegExp('\\s+'),
                    '',
                  );
                  bool fuzzyMatch(String candidate, String queryChars) {
                    final cand = candidate.toLowerCase();
                    for (var i = 0; i < queryChars.length; i++) {
                      if (!cand.contains(queryChars[i])) return false;
                    }
                    return true;
                  }

                  return _allCategories.where((c) => fuzzyMatch(c, cleaned));
                },
                fieldViewBuilder:
                    (
                      context,
                      textEditingController,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      // initialize controller with existing value if any
                      if (_categoryInitial.isNotEmpty &&
                          textEditingController.text.isEmpty) {
                        textEditingController.text = _categoryInitial;
                      }
                      // keep a reference so _save() can read the value
                      _categoryC = textEditingController;
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Catégorie *',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Catégorie requise';
                          }
                          return null;
                        },
                      );
                    },
                onSelected: (s) {
                  // ensure controller updated when user selects an option
                  _categoryC.text = s;
                },
              ),

              // Buttons: Détails and Récurrence (side-by-side)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => setState(() => _expanded = !_expanded),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        child: Text(_expanded ? 'Masquer' : 'Détails'),
                      ),
                      const SizedBox(width: 12),
                      // Récurrence toggle button — affichée pour création et édition
                      ElevatedButton.icon(
                        onPressed: () =>
                            setState(() => _recurrence = !_recurrence),
                        icon: Icon(
                          _recurrence ? Icons.check : Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text('Récurrence'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _recurrence
                              ? Colors.green
                              : Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Hidden details — still part of the form and will be sent on save
              if (_expanded) ...[
                TextFormField(
                  controller: _sourceC,
                  decoration: const InputDecoration(labelText: 'Source'),
                ),
                TextFormField(
                  controller: _destC,
                  decoration: const InputDecoration(labelText: 'Destination'),
                ),
                // costs should not appear for revenue mode
                if (widget.mode != 'revenue')
                  TextFormField(
                    controller: _costsC,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Coûts'),
                  ),
              ],

              // Recurrence fields (masked when _recurrence is false but preserved)
              if (_recurrence)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Récurrence',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Fréquence: '),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _frequency,
                            items: const [
                              DropdownMenuItem(
                                value: 'mensuel',
                                child: Text('mensuel'),
                              ),
                              DropdownMenuItem(
                                value: 'trimestriel',
                                child: Text('trimestriel'),
                              ),
                              DropdownMenuItem(
                                value: 'semestriel',
                                child: Text('semestriel'),
                              ),
                              DropdownMenuItem(
                                value: 'annuel',
                                child: Text('annuel'),
                              ),
                              DropdownMenuItem(
                                value: 'custom',
                                child: Text('custom'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _frequency = v);
                            },
                          ),
                        ],
                      ),
                      if (_frequency == 'custom')
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              // valeur (tous les X)
                              Expanded(
                                child: TextFormField(
                                  controller: _customValueC,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Valeur (tous les X)',
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Requis';
                                    }
                                    if (int.tryParse(v) == null) {
                                      return 'Entier requis';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              // unité
                              DropdownButton<String>(
                                value: _customUnit,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'semaine',
                                    child: Text('semaine'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'mois',
                                    child: Text('mois'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'année',
                                    child: Text('année'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _customUnit = v);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

              CheckboxListTile(
                value: _validated,
                onChanged: (v) {
                  setState(() => _validated = v!);
                },
                title: const Text('Validée'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(onPressed: () => _save(), child: const Text('Enregistrer')),
      ],
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final parsedAmount =
        double.tryParse(_amountC.text.replaceAll(',', '.')) ?? 0.0;
    final parsedCosts =
        double.tryParse(_costsC.text.replaceAll(',', '.')) ?? 0.0;
    double finalAmount = parsedAmount;
    if (widget.mode == 'revenue') {
      finalAmount = parsedAmount.abs();
    } else if (widget.mode == 'depense') {
      finalAmount = -parsedAmount.abs();
    }

    final parsedCostsForSave = widget.mode == 'revenue' ? 0.0 : parsedCosts;
    // If recurrence is enabled, return a subscription payload instead of an operation
    if (_recurrence) {
      int intervalValue = 1;
      String intervalUnit = 'months';
      switch (_frequency) {
        case 'mensuel':
          intervalValue = 1;
          intervalUnit = 'months';
          break;
        case 'trimestriel':
          intervalValue = 3;
          intervalUnit = 'months';
          break;
        case 'semestriel':
          intervalValue = 6;
          intervalUnit = 'months';
          break;
        case 'annuel':
          intervalValue = 12;
          intervalUnit = 'months';
          break;
        case 'custom':
          intervalValue = int.tryParse(_customValueC.text) ?? 1;
          // map french unit to API unit tokens
          if (_customUnit == 'semaine') {
            intervalUnit = 'weeks';
          } else if (_customUnit == 'mois') {
            intervalUnit = 'months';
          } else if (_customUnit == 'année') {
            intervalUnit = 'years';
          }
          break;
      }

      final body = {
        'id': widget.subscription?.id,
        'label': _nameC.text,
        'amount': finalAmount,
        'category': _categoryC.text,
        'source': _sourceC.text.isEmpty ? null : _sourceC.text,
        'destination': _destC.text.isEmpty ? null : _destC.text,
        'costs': parsedCostsForSave,
        'active': true,
        'interval_value': intervalValue,
        'interval_unit': intervalUnit,
        'start_date': _date.toIso8601String(),
        'end_date': null,
        'day_of_month': null,
        'last_generated_at': null,
      };
      // If editing an existing subscription, include its id so callers
      // can perform an update instead of a create.
      if (widget.subscription != null) {
        Navigator.of(
          context,
        ).pop({'subscription': body, 'id': widget.subscription!.id});
      } else {
        Navigator.of(context).pop({'subscription': body});
      }
      return;
    }

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

  String _modeLabel() {
    switch (widget.mode) {
      case 'revenue':
        return 'Revenu';
      case 'depense':
        return 'Dépense';
      case 'abonnement':
        return 'Abonnement';
    }
    return 'opération';
  }
}
