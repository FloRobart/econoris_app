import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/services/api/auth_api_client.dart';
import '../../../../routing/routes.dart';

class CodeEntryPage extends StatefulWidget {
  final String? email;
  final String? name;
  const CodeEntryPage({super.key, this.email, this.name});
  @override
  State<CodeEntryPage> createState() => _CodeEntryPageState();
}

class _CodeEntryPageState extends State<CodeEntryPage> {
  final _codeC = TextEditingController();
  String? _error;
  bool _loading = false;
  String? _resolvedEmail;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final code = _codeC.text.trim().replaceAll(' ', '');
    final email = (widget.email != null && widget.email!.isNotEmpty)
        ? widget.email!
        : (_resolvedEmail ?? '');
    if (email.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Aucun email disponible pour confirmer le code';
      });
      return;
    }
    // retrieve the login token stored after the initial requestLoginCode call
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('login_token') ?? '';
    if (token.isEmpty) {
      setState(() {
        _loading = false;
        _error =
            'Aucun token trouvé pour confirmer la connexion. Veuillez renvoyer le code.';
      });
      return;
    }

    final resp = await AuthApiClient.confirmLoginCode(email, token, code);
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
          // remove temporary login token
          await sp.remove('login_token');
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          return;
        }
      } catch (e, st) {
        debugPrint('confirmLoginCode: parse error: $e\n$st');
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
        debugPrint('confirmLoginCode parse error: $e\n$st');
      }
      setState(() {
        _error = msg;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // attempt to auto-send a code when no email/name were passed to the page
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoSend());
  }

  Future<void> _maybeAutoSend() async {
    // if page was opened with explicit params that include an email,
    // assume caller already sent the code (name is optional)
    if ((widget.email ?? '').isNotEmpty) {
      _resolvedEmail = widget.email;
      return;
    }
    final sp = await SharedPreferences.getInstance();
    final email = sp.getString('email') ?? '';
    if (email.isEmpty) {
      setState(() {
        _error = 'Aucun email trouvé en local. Veuillez vous reconnecter.';
      });
      // navigate back to login after a short delay
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }
    setState(() {
      _error = null;
      _resolvedEmail = email;
    });
    try {
      final resp = await AuthApiClient.requestLoginCode(email);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        // success - expect a token in response body
        try {
          final j = jsonDecode(resp.body);
          final token = j['token'];
          if (token != null && token is String && token.isNotEmpty) {
            await sp.setString('login_token', token);
            setState(() {});
          } else {
            String msg = 'Réponse invalide du serveur';
            setState(() {
              _error = msg;
            });
          }
        } catch (e, st) {
          debugPrint('requestLoginCode: parse error: $e\n$st');
          setState(() {
            _error = 'Réponse invalide du serveur';
          });
        }
      } else if (resp.statusCode >= 500) {
        // server error -> show message like LoginPage
        String msg = 'Erreur lors de l\'envoi du code';
        try {
          final j = jsonDecode(resp.body);
          msg = j['error'] ?? resp.body;
        } catch (e, st) {
          debugPrint('requestLoginCode parse error: $e\n$st');
        }
        setState(() {
          _error = msg;
        });
      } else if (resp.statusCode >= 400 && resp.statusCode < 500) {
        // client error -> clear local creds and redirect to login with API message
        String msg = 'Erreur';
        try {
          final j = jsonDecode(resp.body);
          msg = j['error'] ?? resp.body;
        } catch (e, st) {
          debugPrint('requestLoginCode parse error: $e\n$st');
        }
        final sp = await SharedPreferences.getInstance();
        await sp.remove('jwt');
        await sp.remove('email');
        if (!mounted) return;
        // navigate to login and pass the error message to display
        Navigator.of(
          context,
        ).pushReplacementNamed(AppRoutes.login, arguments: {'error': msg});
        return;
      } else {
        String msg = 'Erreur inconnue lors de l\'envoi du code';
        setState(() {
          _error = msg;
        });
      }
    } catch (e, st) {
      debugPrint('requestLoginCode: network error: $e\n$st');
      setState(() {
        _error = 'Erreur réseau lors de l\'envoi du code';
      });
    } finally {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Vérification'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 400,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Un code à 6 chiffres a été envoyé à ${widget.email}'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _codeC,
                    decoration: const InputDecoration(
                      labelText: 'Code (6 chiffres)',
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: const Text('Valider'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
