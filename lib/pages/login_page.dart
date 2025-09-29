import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../services/api_service.dart';
import '../navigation/app_routes.dart';

class LoginPage extends StatefulWidget {
  final String? initialError;
  const LoginPage({super.key, this.initialError});
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
  if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.codeEntry, arguments: {'email': email, 'name': name});
    } else {
      String msg = 'Erreur';
      try { final j = jsonDecode(resp.body); msg = j['error'] ?? resp.body; } catch (e) {}
      setState(() { _error = msg; });
    }
  }

  @override
  void initState() {
    super.initState();
    // populate any initial error passed via navigation arguments
    _error = widget.initialError;
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
                Row(children: [Image.asset('assets/logo/econoris_logo-1024.png', width: 48, height: 48), const SizedBox(width: 8), Text(Config.appName, style: const TextStyle(fontSize: 22))]),
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
