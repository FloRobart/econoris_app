import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../providers/auth/auth_repository_provider.dart';

class CodeEntryViewModel extends ChangeNotifier {
  final Ref _ref;

  CodeEntryViewModel(this._ref);

  String? error;
  bool loading = false;
  String? resolvedEmail;
  bool _autoSent = false;

  void _setLoading(bool v) {
    loading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    error = e;
    notifyListeners();
  }

  /// Tentative d'envoi automatique du code si aucun email fourni.
  Future<void> maybeAutoSend({String? email, String? name}) async {
    if (_autoSent) return;
    _autoSent = true;

    if ((email ?? '').isNotEmpty) {
      resolvedEmail = email;
      notifyListeners();
      return;
    }

    final sp = await SharedPreferences.getInstance();
    final localEmail = sp.getString('email') ?? '';
    if (localEmail.isEmpty) {
      _setError('Aucun email trouvé en local. Veuillez vous reconnecter.');
      return;
    }

    _setError(null);
    resolvedEmail = localEmail;
    notifyListeners();

    _setLoading(true);
    try {
      final repo = await _ref.read(authRepositoryProvider.future);
      await repo.requestLoginCode(localEmail);
    } catch (e, st) {
      if (kDebugMode) debugPrint('maybeAutoSend error: $e\n$st');
      _setError('Erreur réseau lors de l\'envoi du code');
    } finally {
      _setLoading(false);
    }
  }

  /// Soumet le code saisi. Retourne true si succès.
  Future<bool> submit(String code, {String? email}) async {
    _setLoading(true);
    _setError(null);
    try {
      // use repository which will read saved token/email as needed
      final repo = await _ref.read(authRepositoryProvider.future);
      await repo.confirmLoginCode(code);
      return true;
    } catch (e, st) {
      if (kDebugMode) debugPrint('confirmLoginCode error: $e\n$st');
      _setError('Erreur lors de la confirmation du code');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}

final codeEntryViewModelProvider = ChangeNotifierProvider<CodeEntryViewModel>((ref) => CodeEntryViewModel(ref));
