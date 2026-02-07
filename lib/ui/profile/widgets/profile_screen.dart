import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../data/services/api/auth_api_client.dart';
import '../../../data/services/global_data.dart';
import '../../../routing/routes.dart';
import '../../core/themes/theme_manager.dart';
import '../../core/ui/app_scaffold.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _jwt;
  String? _email;
  String? _name;
  String? _error;
  int? id;
  bool? _isConnected;
  bool? _isVerifiedEmail;
  DateTime? _createdAt;
  String? _appVersion;
  bool _loading = true;
  final _nameC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    // clean listeners and controllers
    ThemeManager.instance.notifier.removeListener(_onThemeChanged);
    _nameC.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    _jwt = sp.getString('jwt');
    _email = sp.getString('email');
    // We no longer store the user's name locally; the profile will be
    // fetched from the API when available.
    if (_jwt != null) {
      try {
        await GlobalData.instance.ensureData(_jwt!);
        final j = GlobalData.instance.profile;
        if (j != null) {
          setState(() {
            id = j['id'];
            _email = j['email'];
            _name = j['pseudo'] ?? j['name'];
            _nameC.text = _name ?? '';
            _isConnected = j['is_connected'];
            _isVerifiedEmail = j['is_verified_email'];
            _createdAt = j['created_at'] == null
                ? null
                : DateTime.tryParse(j['created_at']?.toString() ?? '');
            _error = null;
            _loading = false;
          });
        } else {
          setState(() => _loading = false);
        }
      } catch (e) {
        // If the central fetch failed, behave as before and show error
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    } else {
      setState(() => _loading = false);
    }
    // load theme preference
    _themeMode = ThemeManager.instance.mode;
    ThemeManager.instance.notifier.addListener(_onThemeChanged);

    // load package info (version)
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${info.version}+${info.buildNumber}';
      });
    } catch (e, st) {
      debugPrint('PackageInfo error: $e\n$st');
    }
  }

  void _onThemeChanged() {
    setState(() {
      _themeMode = ThemeManager.instance.notifier.value;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (_jwt != null) await AuthApiClient.logout(_jwt!);
    final sp = await SharedPreferences.getInstance();
    await sp.remove('jwt');
    GlobalData.instance.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Session expirée')));
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
  }

  Future<void> _deleteAccount() async {
    if (_jwt == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer mon compte'),
        content: const Text(
          'Cette action est irréversible. Confirmer la suppression de votre compte ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    // attempt delete and clear local state
    await AuthApiClient.deleteUser(_jwt!);
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
    GlobalData.instance.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compte supprimé, session terminée')),
    );
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
  }

  Future<void> _updateName() async {
    if (_jwt == null) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final newName = _nameC.text.trim();
    final resp = await AuthApiClient.updateUser(_jwt!, _email ?? '', newName);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (!mounted) return;
      setState(() => _name = newName);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nom mis à jour')));
    } else {
      String m = 'Erreur';
      try {
        m = jsonDecode(resp.body)['error'] ?? resp.body;
      } catch (e, st) {
        debugPrint('updateUser parse error: $e\n$st');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // Profile is not part of the bottom navigation anymore; indicate this
      // by passing null so AppScaffold will highlight the profile instead
      // of any bottom tab.
      currentIndex: null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profil',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),

                  // Header card with avatar and basic info
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            child: Text(
                              ((_name ?? _email ?? '')
                                  .split(' ')
                                  .where((s) => s.isNotEmpty)
                                  .map((s) => s[0].toUpperCase())
                                  .take(2)
                                  .join()),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _name ?? '—',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _email ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Show API error if any
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),

                  // Account status summary (from API)
                  if (_isConnected != null ||
                      _isVerifiedEmail != null ||
                      _createdAt != null)
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Statut du compte',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            if (_isConnected != null)
                              Row(
                                children: [
                                  const Icon(Icons.link),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Connecté : ${_isConnected! ? 'Oui' : 'Non'}',
                                  ),
                                ],
                              ),
                            if (_isConnected != null) const SizedBox(height: 6),
                            if (_isVerifiedEmail != null)
                              Row(
                                children: [
                                  const Icon(Icons.email),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Email vérifié : ${_isVerifiedEmail! ? 'Oui' : 'Non'}',
                                  ),
                                ],
                              ),
                            if (_isVerifiedEmail != null)
                              const SizedBox(height: 6),
                            if (_createdAt != null)
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Créé le : ${_createdAt != null ? _createdAt!.toLocal().toString().split('.').first : ''}',
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Form card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informations',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nameC,
                              decoration: const InputDecoration(
                                labelText: 'Nom complet',
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (v) => (v ?? '').trim().isEmpty
                                  ? 'Le nom ne peut pas être vide'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: _email,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Theme selector
                            Row(
                              children: [
                                const Icon(Icons.color_lens),
                                const SizedBox(width: 12),
                                const Text('Thème'),
                                const Spacer(),
                                DropdownButton<ThemeMode>(
                                  value: _themeMode,
                                  items: const [
                                    DropdownMenuItem(
                                      value: ThemeMode.system,
                                      child: Text('Auto'),
                                    ),
                                    DropdownMenuItem(
                                      value: ThemeMode.light,
                                      child: Text('Clair'),
                                    ),
                                    DropdownMenuItem(
                                      value: ThemeMode.dark,
                                      child: Text('Sombre'),
                                    ),
                                  ],
                                  onChanged: (m) async {
                                    if (m == null) return;
                                    await ThemeManager.instance.setMode(m);
                                    setState(() {
                                      _themeMode = m;
                                    });
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Actions
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _updateName,
                                    icon: const Icon(Icons.save),
                                    label: const Text('Enregistrer'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _logout,
                                    icon: const Icon(Icons.logout),
                                    label: const Text('Déconnexion'),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),
                            Center(
                              child: TextButton(
                                onPressed: _deleteAccount,
                                child: const Text(
                                  'Supprimer mon compte',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  if (_appVersion != null)
                    Center(
                      child: Text(
                        'Version : $_appVersion',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
    );
  }
}
