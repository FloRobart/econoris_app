import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../services/api_service.dart';
import '../routing/app_routes.dart';

class LoginPage extends StatefulWidget {
  final String? initialError;

  /// When true the page will ask for the user's name (used for signup).
  /// When false the name field is hidden and the button text becomes "Se connecter".
  final bool requireName;
  const LoginPage({super.key, this.initialError, this.requireName = true});

  /// Convenience constructor for the login (no name required).
  const LoginPage.login({Key? key, String? initialError})
      : this(key: key, initialError: initialError, requireName: false);

  /// Convenience constructor for the signup (name required).
  const LoginPage.signup({Key? key, String? initialError})
      : this(key: key, initialError: initialError, requireName: true);

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
    setState(() {
      _loading = true;
      _error = null;
    });
    final email = _emailC.text.trim();
    final name = _nameC.text.trim();
    final sp = await SharedPreferences.getInstance();
    await sp.setString('email', email);
    // We no longer persist the user's name locally.

    // If a name was provided we treat this as the signup flow which calls
    // the register endpoint and expects a JWT back. If only the email was
    // provided we call the requestLoginCode endpoint (login by code).
    if (_requireName && name.isNotEmpty) {
      // Signup -> registerUser (expect immediate JWT)
      final resp = await ApiService.registerUser(email, name);
      setState(() {
        _loading = false;
      });
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        try {
          final j = jsonDecode(resp.body);
          final jwt = j['jwt'];
          if (jwt != null) {
            final sp = await SharedPreferences.getInstance();
            await sp.setString('jwt', jwt);
            await sp.setString('email', email);
            if (!mounted) return;
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            return;
          }
        } catch (e, st) {
          debugPrint('registerUser: parse error: $e\n$st');
        }
        setState(() {
          _error = 'Réponse invalide du serveur';
        });
      } else {
        String msg = 'Erreur';
        try {
          final j = jsonDecode(resp.body);
          msg = j['error'] ?? resp.body;
        } catch (e, st) {
          debugPrint('registerUser parse error: $e\n$st');
        }
        setState(() {
          _error = msg;
        });
      }
    } else {
      // Login -> requestLoginCode and go to code entry
      final resp = await ApiService.requestLoginCode(email);
      setState(() {
        _loading = false;
      });
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        // Expect the server to return a token to be used when confirming the code
        try {
          final j = jsonDecode(resp.body);
          final token = j['token'];
          if (token != null && token is String && token.isNotEmpty) {
            final sp = await SharedPreferences.getInstance();
            await sp.setString('login_token', token);
            if (!mounted) return;
            Navigator.of(context).pushReplacementNamed(AppRoutes.codeEntry,
                arguments: {'email': email});
            return;
          }
        } catch (e, st) {
          debugPrint('requestLoginCode: parse error: $e\n$st');
        }
        setState(() {
          _error = 'Réponse invalide du serveur';
        });
      } else {
        String msg = 'Erreur';
        try {
          final j = jsonDecode(resp.body);
          msg = j['error'] ?? resp.body;
        } catch (e, st) {
          debugPrint('requestLoginCode: parse error: $e\n$st');
        }
        setState(() {
          _error = msg;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // populate any initial error passed via navigation arguments
    _error = widget.initialError;
    _requireName = widget.requireName;
    // Load any saved email from shared preferences to prefill the email field.
    // This only pre-fills the text field; it does not auto-submit the form.
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final saved = sp.getString('email');
      if (saved != null && saved.isNotEmpty) {
        // Only update the controller if it's currently empty to avoid
        // overwriting any user-typed content when returning to the page.
        if (_emailC.text.trim().isEmpty) {
          setState(() {
            _emailC.text = saved;
          });
        }
      }
    } catch (e, st) {
      debugPrint('loadSavedEmail error: $e\n$st');
      // ignore errors reading prefs; field will stay empty
    }
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
                Row(children: [
                  Image.asset('logo/econoris_logo-512.png',
                      width: 48, height: 48),
                  const SizedBox(width: 8),
                  Text(Config.appName, style: const TextStyle(fontSize: 22))
                ]),
                const SizedBox(height: 12),
                TextField(
                    controller: _emailC,
                    decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 8),
                if (_requireName) ...[
                  TextField(
                      controller: _nameC,
                      decoration: const InputDecoration(labelText: 'Prenom')),
                  const SizedBox(height: 12),
                ],
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                // add a bit more space above the toggle
                const SizedBox(height: 14),
                // Toggle between signup and login
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_requireName
                      ? 'Déjà un compte ?'
                      : "Pas encore de compte ?"),
                  TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                              setState(() {
                                _requireName = !_requireName;
                                if (!_requireName) _nameC.text = '';
                              });
                            },
                      child: Text(_requireName ? 'Se connecter' : "S'inscrire"))
                ]),
                // add a bit more space below the toggle
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w600),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
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
