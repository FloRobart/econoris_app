import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';
import '../services/api_service.dart';
import 'subscription_dialogs.dart';

typedef SubscriptionCreatedCallback = void Function(Subscription subscription);

class AddSubscriptionFab extends StatefulWidget {
  final SubscriptionCreatedCallback? onSubscriptionCreated;
  const AddSubscriptionFab({super.key, this.onSubscriptionCreated});

  @override
  State<AddSubscriptionFab> createState() => _AddSubscriptionFabState();
}

class _AddSubscriptionFabState extends State<AddSubscriptionFab> {
  Future<void> _openCreate() async {
    final res = await showDialog<Subscription>(context: context, builder: (_) => const SubscriptionCreateDialog());
    if (res == null) return;
    final sp = await SharedPreferences.getInstance();
    final jwt = sp.getString('jwt');
    if (jwt == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Non authentifié')));
      return;
    }
    final body = res.toJson();
    final resp = await ApiService.addSubscription(jwt, body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      try {
        final parsed = jsonDecode(resp.body);
        Map<String,dynamic>? subJson;
        if (parsed is Map && parsed.containsKey('subscription') && parsed['subscription'] is Map) subJson = Map<String,dynamic>.from(parsed['subscription']);
        else if (parsed is Map && parsed.containsKey('data') && parsed['data'] is Map) subJson = Map<String,dynamic>.from(parsed['data']);
        else if (parsed is Map) subJson = Map<String,dynamic>.from(parsed);
        else if (parsed is List && parsed.isNotEmpty && parsed[0] is Map) subJson = Map<String,dynamic>.from(parsed[0]);

        if (subJson != null) {
          final created = Subscription.fromJson(subJson);
          widget.onSubscriptionCreated?.call(created);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abonnement ajouté')));
          return;
        }
      } catch (e, st) {
        debugPrint('addSubscription parse error: $e\n$st');
      }
      widget.onSubscriptionCreated?.call(res);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abonnement ajouté')));
    } else {
      String m = 'Erreur';
      try { final p = jsonDecode(resp.body); if (p is Map && p.containsKey('error')) m = p['error'].toString(); else m = resp.body; } catch (_) {}
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(onPressed: _openCreate, child: const Icon(Icons.add));
  }
}
