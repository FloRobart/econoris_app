import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../navigation/app_routes.dart';

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
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
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
