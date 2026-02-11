import 'dart:convert';
import 'package:econoris_app/data/services/api/subscriptions_api_client.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/services/api/operations_api_client.dart';
import '../../../data/services/global_data.dart';
import '../../../domain/models/operations/operation.dart';
import '../../../domain/models/subscriptions/subscription.dart';
import 'add_operation_button.dart';
import 'operation_dialogs.dart';

typedef OperationCreatedCallback = void Function(Operation operation);

/// Reusable add-operation FAB with a small speed-dial showing three choices.
class AddOperationFab extends StatefulWidget {
  final OperationCreatedCallback? onOperationCreated;

  /// Optional list of current operations to derive category suggestions.
  final List<Operation>? operations;

  /// Optional list of subscriptions to also derive category suggestions from.
  final List<Subscription>? subscriptions;
  const AddOperationFab({
    super.key,
    this.onOperationCreated,
    this.operations,
    this.subscriptions,
  });

  /// Helper to open the subscription editor (create or edit) using the
  /// same UI/logic as the add-operation FAB. Returns true when the
  /// subscription was created/updated successfully.
  static Future<bool> showSubscriptionEditor(
    BuildContext context, {
    Subscription? subscription,
    List<Operation>? operations,
    List<Subscription>? subscriptions,
    VoidCallback? onUpdated,
  }) async {
    final res = await showDialog(
      context: context,
      builder: (_) => OperationEditDialog(
        mode: 'abonnement',
        subscription: subscription,
        operations: operations,
        subscriptions: subscriptions,
      ),
    );
    if (res == null) return false;

    final sp = await SharedPreferences.getInstance();
    final jwt = sp.getString('jwt');
    if (jwt == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Non authentifié')));
      }
      return false;
    }

    if (res is Map && res.containsKey('subscription')) {
      final body = res['subscription'] as Map<String, dynamic>;
      // If an id is present -> update, else create
      if (res.containsKey('id')) {
        final id = res['id'] as int;
        final resp = await SubscriptionsApiClient.updateSubscription(id, body);
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          // try to parse returned subscription and update central store
          try {
            final parsed = jsonDecode(resp.body);
            Map<String, dynamic>? subJson;
            if (parsed is Map<String, dynamic>) {
              if (parsed.containsKey('subscription') &&
                  parsed['subscription'] is Map) {
                subJson = Map<String, dynamic>.from(parsed['subscription']);
              } else if (parsed.containsKey('data') && parsed['data'] is Map) {
                subJson = Map<String, dynamic>.from(parsed['data']);
              } else {
                subJson = Map<String, dynamic>.from(parsed);
              }
            }
            if (subJson != null) {
              GlobalData.instance.upsertSubscriptionFromJson(subJson);
            }
          } catch (_) {}
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Abonnement modifié')));
          }
          try {
            onUpdated?.call();
          } catch (_) {}
          return true;
        } else {
          String m = 'Erreur';
          try {
            final p = jsonDecode(resp.body);
            if (p is Map && p.containsKey('error')) {
              m = p['error'].toString();
            } else {
              m = resp.body;
            }
          } catch (_) {}
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(m)));
          }
          return false;
        }
      } else {
        final resp = await SubscriptionsApiClient.addSubscription(body);
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          // parse created subscription and update global store
          try {
            final parsed = jsonDecode(resp.body);
            Map<String, dynamic>? subJson;
            if (parsed is Map<String, dynamic>) {
              if (parsed.containsKey('subscription') &&
                  parsed['subscription'] is Map) {
                subJson = Map<String, dynamic>.from(parsed['subscription']);
              } else if (parsed.containsKey('data') && parsed['data'] is Map) {
                subJson = Map<String, dynamic>.from(parsed['data']);
              } else if (parsed.containsKey('row') && parsed['row'] is Map) {
                subJson = Map<String, dynamic>.from(parsed['row']);
              } else if (parsed.containsKey('rows') &&
                  parsed['rows'] is List &&
                  (parsed['rows'] as List).isNotEmpty &&
                  (parsed['rows'][0] is Map)) {
                subJson = Map<String, dynamic>.from(parsed['rows'][0]);
              } else if (parsed.containsKey('result') &&
                  parsed['result'] is Map) {
                subJson = Map<String, dynamic>.from(parsed['result']);
              } else {
                subJson = Map<String, dynamic>.from(parsed);
              }
            } else if (parsed is List &&
                parsed.isNotEmpty &&
                parsed[0] is Map) {
              subJson = Map<String, dynamic>.from(parsed[0]);
            }
            if (subJson != null) {
              GlobalData.instance.upsertSubscriptionFromJson(subJson);
            }
          } catch (_) {}
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Abonnement ajouté')));
          }
          try {
            onUpdated?.call();
          } catch (_) {}
          return true;
        } else {
          String m = 'Erreur';
          try {
            final p = jsonDecode(resp.body);
            if (p is Map && p.containsKey('error')) {
              m = p['error'].toString();
            } else {
              m = resp.body;
            }
          } catch (_) {}
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(m)));
          }
          return false;
        }
      }
    }

    return false;
  }

  @override
  State<AddOperationFab> createState() => _AddOperationFabState();
}

class _AddOperationFabState extends State<AddOperationFab> {
  Future<void> _openAddModalWithMode(String mode) async {
    final res = await showDialog(
      context: context,
      builder: (_) => OperationEditDialog(
        mode: mode,
        operations: widget.operations,
        subscriptions: widget.subscriptions,
      ),
    );
    if (res == null) return;

    final sp = await SharedPreferences.getInstance();
    final jwt = sp.getString('jwt');
    if (jwt == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Non authentifié')));
      return;
    }

    // If the dialog returned a subscription payload, call addSubscription
    if (res is Map && res.containsKey('subscription')) {
      final body = res['subscription'] as Map<String, dynamic>;
      final resp = await SubscriptionsApiClient.addSubscription(body);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        // parse created subscription and update global store so UI updates without a full refetch
        try {
          final parsed = jsonDecode(resp.body);
          Map<String, dynamic>? subJson;
          if (parsed is Map<String, dynamic>) {
            if (parsed.containsKey('subscription') &&
                parsed['subscription'] is Map) {
              subJson = Map<String, dynamic>.from(parsed['subscription']);
            } else if (parsed.containsKey('data') && parsed['data'] is Map) {
              subJson = Map<String, dynamic>.from(parsed['data']);
            } else if (parsed.containsKey('row') && parsed['row'] is Map) {
              subJson = Map<String, dynamic>.from(parsed['row']);
            } else if (parsed.containsKey('rows') &&
                parsed['rows'] is List &&
                (parsed['rows'] as List).isNotEmpty &&
                (parsed['rows'][0] is Map)) {
              subJson = Map<String, dynamic>.from(parsed['rows'][0]);
            } else if (parsed.containsKey('result') &&
                parsed['result'] is Map) {
              subJson = Map<String, dynamic>.from(parsed['result']);
            } else {
              subJson = Map<String, dynamic>.from(parsed);
            }
          } else if (parsed is List && parsed.isNotEmpty && parsed[0] is Map) {
            subJson = Map<String, dynamic>.from(parsed[0]);
          }
          if (subJson != null) {
            GlobalData.instance.upsertSubscriptionFromJson(subJson);
          }
        } catch (e, st) {
          debugPrint('addSubscription parse error: $e\n$st');
        }
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Abonnement ajouté')));
        return;
      } else {
        String m = 'Erreur';
        try {
          final p = jsonDecode(resp.body);
          if (p is Map && p.containsKey('error')) {
            m = p['error'].toString();
          } else {
            m = resp.body;
          }
        } catch (e, st) {
          debugPrint('addSubscription parse error: $e\n$st');
        }
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
        return;
      }
    }

    final body = (res as Operation).toJson();
    final resp = await OperationsApiClient.addOperation(body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      try {
        final parsed = jsonDecode(resp.body);
        Map<String, dynamic>? opJson;
        if (parsed is Map<String, dynamic>) {
          if (parsed.containsKey('operation') && parsed['operation'] is Map) {
            opJson = Map<String, dynamic>.from(parsed['operation']);
          } else if (parsed.containsKey('rows') &&
              parsed['rows'] is List &&
              (parsed['rows'] as List).isNotEmpty &&
              (parsed['rows'][0] is Map)) {
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
          // update central store so UI updates without needing a full refetch
          try {
            GlobalData.instance.upsertOperationFromJson(opJson);
          } catch (_) {}
          widget.onOperationCreated?.call(created);
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Opération ajoutée')));
          return;
        }
      } catch (e, st) {
        debugPrint('addOperation parse error: $e\n$st');
      }
      // Fallback: still notify parent to refresh
      widget.onOperationCreated?.call(res);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Opération ajoutée')));
    } else {
      String m = 'Erreur';
      try {
        final p = jsonDecode(resp.body);
        if (p is Map && p.containsKey('error')) {
          m = p['error'].toString();
        } else {
          m = resp.body;
        }
      } catch (e, st) {
        debugPrint('addOperation parse error: $e\n$st');
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // Use the new reusable AddOperationButton widget for the '+' button and
    // its small action items. We pass the distinct list of categories available
    // (fallback to empty list) and forward selections to the existing modal
    // handler.
    // combine categories from subscriptions and operations preserving first-seen order
    final seen = <String>{};
    final cats = <String>[];
    if (widget.subscriptions != null) {
      for (final s in widget.subscriptions!) {
        try {
          final c = (s as dynamic).category as String?;
          if (c != null && c.isNotEmpty && !seen.contains(c)) {
            seen.add(c);
            cats.add(c);
          }
        } catch (_) {}
      }
    }
    if (widget.operations != null) {
      for (final o in widget.operations!) {
        final c = o.category;
        if (c.isNotEmpty && !seen.contains(c)) {
          seen.add(c);
          cats.add(c);
        }
      }
    }

    return AddOperationButton(
      categories: cats,
      onModeSelected: (mode) => _openAddModalWithMode(mode),
    );
  }
}
