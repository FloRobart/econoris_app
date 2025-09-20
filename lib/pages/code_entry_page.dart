import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../navigation/app_routes.dart';

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
  bool _sendingCode = false;
  String? _sentNotice;
  String? _resolvedEmail;

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    final code = _codeC.text.trim();
    final email = (widget.email != null && widget.email!.isNotEmpty) ? widget.email! : (_resolvedEmail ?? '');
    if (email.isEmpty) {
      setState(() { _loading = false; _error = 'Aucun email disponible pour confirmer le code'; });
      return;
    }
    final resp = await ApiService.confirmLoginCode(email, code);
    setState(() { _loading = false; });
    if (resp.statusCode == 200) {
      try {
        final j = jsonDecode(resp.body);
        final jwt = j['jwt'];
        if (jwt != null) {
          final sp = await SharedPreferences.getInstance();
          await sp.setString('jwt', jwt);
          await sp.setString('email', email);
          await sp.setString('name', widget.name ?? '');
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
  void initState() {
    super.initState();
    // attempt to auto-send a code when no email/name were passed to the page
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoSend());
  }

  Future<void> _maybeAutoSend() async {
    // if page was opened with explicit params, assume caller already sent the code
    if ((widget.email ?? '').isNotEmpty && (widget.name ?? '').isNotEmpty) {
      _resolvedEmail = widget.email;
      return;
    }
    final sp = await SharedPreferences.getInstance();
    final email = sp.getString('email') ?? '';
    final name = sp.getString('name') ?? '';
    if (email.isEmpty || name.isEmpty) {
      setState(() { _error = 'Aucun email trouvé en local. Veuillez vous reconnecter.'; });
      // navigate back to login after a short delay
      await Future.delayed(const Duration(seconds: 2));
  if (!mounted) return;
  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }
    setState(() { _sendingCode = true; _error = null; _resolvedEmail = email; });
    try {
      final resp = await ApiService.requestLoginCode(email, name);
      if (resp.statusCode >= 200 && resp.statusCode < 400) {
        // success
        setState(() { _sentNotice = 'Un code a été envoyé à $email'; });
      } else if (resp.statusCode >= 500) {
        // server error -> show message like LoginPage
        String msg = 'Erreur lors de l\'envoi du code';
        try { final j = jsonDecode(resp.body); msg = j['error'] ?? resp.body; } catch (e) {}
        setState(() { _error = msg; });
      } else if (resp.statusCode >= 400 && resp.statusCode < 500) {
        // client error -> clear local creds and redirect to login with API message
        String msg = 'Erreur';
        try { final j = jsonDecode(resp.body); msg = j['error'] ?? resp.body; } catch (e) {}
        final sp = await SharedPreferences.getInstance();
        await sp.remove('jwt');
        await sp.remove('email');
        await sp.remove('name');
  if (!mounted) return;
  // navigate to login and pass the error message to display
  Navigator.of(context).pushReplacementNamed(AppRoutes.login, arguments: {'error': msg});
        return;
      } else {
        String msg = 'Erreur inconnue lors de l\'envoi du code';
        setState(() { _error = msg; });
      }
    } catch (e) {
      setState(() { _error = 'Erreur réseau lors de l\'envoi du code'; });
    } finally {
      setState(() { _sendingCode = false; });
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
