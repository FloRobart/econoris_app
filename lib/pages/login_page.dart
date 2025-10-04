import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../services/api_service.dart';
import '../navigation/app_routes.dart';

class LoginPage extends StatefulWidget {
  final String? initialError;
  /// When true the page will ask for the user's name (used for signup).
  /// When false the name field is hidden and the button text becomes "Se connecter".
  final bool requireName;
  const LoginPage({super.key, this.initialError, this.requireName = true});

  /// Convenience constructor for the login (no name required).
  const LoginPage.login({Key? key, String? initialError}) : this(key: key, initialError: initialError, requireName: false);

  /// Convenience constructor for the signup (name required).
  const LoginPage.signup({Key? key, String? initialError}) : this(key: key, initialError: initialError, requireName: true);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailC = TextEditingController();
  final _nameC = TextEditingController();
  bool _loading = false;
  String? _error;
  late bool _requireName;

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    final email = _emailC.text.trim();
    final name = _nameC.text.trim();
    final sp = await SharedPreferences.getInstance();
    await sp.setString('email', email);
    if (_requireName) {
      await sp.setString('name', name);
    } else {
      // remove any previously stored name when in login mode
      await sp.remove('name');
    }

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
    _requireName = widget.requireName;
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
                if (_requireName) ...[
                  TextField(controller: _nameC, decoration: const InputDecoration(labelText: 'Prenom')),
                  const SizedBox(height: 12),
                ],
                if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                // add a bit more space above the toggle
                const SizedBox(height: 14),
                // Toggle between signup and login
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_requireName ? 'Déjà un compte ?' : "Pas encore de compte ?"),
                  TextButton(onPressed: _loading ? null : () {
                    setState(() {
                      _requireName = !_requireName;
                      if (!_requireName) _nameC.text = '';
                    });
                  }, child: Text(_requireName ? 'Se connecter' : "S'inscrire"))
                ]),
                // add a bit more space below the toggle
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_requireName ? "S'inscrire" : 'Se connecter'),
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
