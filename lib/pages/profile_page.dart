import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/theme_manager.dart';
import '../navigation/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _jwt;
  String? _email;
  String? _name;
  bool _loading = true;
  final _nameC = TextEditingController();
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    _jwt = sp.getString('jwt');
    _email = sp.getString('email');
    _name = sp.getString('name');
    _nameC.text = _name ?? '';
    if (_jwt != null) {
      final resp = await ApiService.getProfile(_jwt!);
      if (resp.statusCode == 200) {
        try { final j = jsonDecode(resp.body); setState((){ _email = j['email'] ?? _email; _name = j['name'] ?? _name; _nameC.text = _name ?? ''; _loading = false; }); } catch (e) { setState(()=> _loading = false); }
      } else {
        setState(()=> _loading = false);
      }
    } else {
      setState(()=> _loading = false);
    }
    // load theme preference
    _themeMode = ThemeManager.instance.mode;
    ThemeManager.instance.notifier.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    setState(() { _themeMode = ThemeManager.instance.notifier.value; });
  }

  Future<void> _logout() async {
    if (_jwt != null) await ApiService.logout(_jwt!);
    final sp = await SharedPreferences.getInstance();
    await sp.remove('jwt');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session expirée')));
    await Future.delayed(const Duration(milliseconds: 400));
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
  }

  Future<void> _deleteAccount() async {
    if (_jwt == null) return;
    await ApiService.deleteUser(_jwt!);
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session expirée')));
    await Future.delayed(const Duration(milliseconds: 400));
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
  }

  Future<void> _updateName() async {
    if (_jwt == null) return;
    final newName = _nameC.text.trim();
    final resp = await ApiService.updateUser(_jwt!, _email ?? '', newName);
    if (resp.statusCode == 200) {
      final sp = await SharedPreferences.getInstance();
      await sp.setString('name', newName);
      setState(()=> _name = newName);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nom mis à jour')));
    } else {
      String m = 'Erreur'; try { m = jsonDecode(resp.body)['error'] ?? resp.body; } catch (e) {}
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        ListTile(title: const Text('Email'), subtitle: Text(_email ?? '')),
        TextField(controller: _nameC, decoration: const InputDecoration(labelText: 'Nom')),
        const SizedBox(height: 12),
        // Theme selector
        Row(children: [const Text('Thème : '), const SizedBox(width: 8), DropdownButton<ThemeMode>(
          value: _themeMode,
          items: const [
            DropdownMenuItem(value: ThemeMode.system, child: Text('Auto')),
            DropdownMenuItem(value: ThemeMode.light, child: Text('Clair')),
            DropdownMenuItem(value: ThemeMode.dark, child: Text('Sombre')),
          ],
          onChanged: (m) async {
            if (m == null) return;
            await ThemeManager.instance.setMode(m);
            setState(() { _themeMode = m; });
          },
        )]),
        const SizedBox(height: 12),
        Row(children: [ElevatedButton(onPressed: _updateName, child: const Text('Enregistrer')), const SizedBox(width: 12), OutlinedButton(onPressed: _logout, child: const Text('Déconnexion')), const SizedBox(width: 12), TextButton(onPressed: _deleteAccount, child: const Text('Supprimer mon compte', style: TextStyle(color: Colors.red)))],)
      ])));
  }
}
