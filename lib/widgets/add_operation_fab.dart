import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/operation.dart';
import '../services/api_service.dart';
import 'operation_dialogs.dart';

typedef OperationCreatedCallback = void Function(Operation operation);

/// Reusable add-operation FAB with a small speed-dial showing three choices.
class AddOperationFab extends StatefulWidget {
  final OperationCreatedCallback? onOperationCreated;
  /// Optional list of current operations to derive category suggestions.
  final List<Operation>? operations;
  const AddOperationFab({super.key, this.onOperationCreated, this.operations});

  @override
  State<AddOperationFab> createState() => _AddOperationFabState();
}

class _AddOperationFabState extends State<AddOperationFab> {
  bool _open = false;

  Future<void> _openAddModalWithMode(String mode) async {
  final res = await showDialog<Operation>(context: context, builder: (_) => OperationEditDialog(mode: mode, operations: widget.operations));
    if (res == null) return;

    final sp = await SharedPreferences.getInstance();
    final jwt = sp.getString('jwt');
    if (jwt == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Non authentifié')));
      return;
    }

    final body = res.toJson();
    final resp = await ApiService.addOperation(jwt, body);
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
          widget.onOperationCreated?.call(created);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opération ajoutée')));
          return;
        }
      } catch (e) {
        // ignore and fallback
      }
      // Fallback: still notify parent to refresh
      widget.onOperationCreated?.call(res);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opération ajoutée')));
    } else {
      String m = 'Erreur';
      try { final p = jsonDecode(resp.body); if (p is Map && p.containsKey('error')) m = p['error'].toString(); else m = resp.body; } catch (e) {}
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSlide(
          offset: _open ? const Offset(0, 0) : const Offset(0, 0.2),
          duration: const Duration(milliseconds: 200),
          child: AnimatedOpacity(
            opacity: _open ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () { setState(() => _open = false); _openAddModalWithMode('revenue'); },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Material(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(24),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () { setState(()=> _open = false); _openAddModalWithMode('revenue'); },
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

        AnimatedSlide(
          offset: _open ? const Offset(0, 0) : const Offset(0, 0.2),
          duration: const Duration(milliseconds: 220),
          child: AnimatedOpacity(
            opacity: _open ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 220),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () { setState(()=> _open = false); _openAddModalWithMode('depense'); },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Material(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(24),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () { setState(()=> _open = false); _openAddModalWithMode('depense'); },
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

        AnimatedSlide(
          offset: _open ? const Offset(0, 0) : const Offset(0, 0.2),
          duration: const Duration(milliseconds: 240),
          child: AnimatedOpacity(
            opacity: _open ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 240),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () { setState(()=> _open = false); _openAddModalWithMode('abonnement'); },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Material(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(24),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () { setState(()=> _open = false); _openAddModalWithMode('abonnement'); },
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

        FloatingActionButton(
          onPressed: () => setState(() => _open = !_open),
          child: AnimatedRotation(
            turns: _open ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
