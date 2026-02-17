// Routeur racine de l'application.
// Ce fichier gère la navigation initiale selon l'état d'authentification
// (présence d'un JWT en local) et réagit aux événements d'expiration
// de session produits par `AuthManager`.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/services/auth_manager.dart';
import '../ui/auth/login/widgets/login_screen.dart';
import '../ui/home/widgets/home_screen.dart';
import 'routes.dart';

/// Widget racine qui décide quelle page afficher au démarrage.
///
/// - Si un JWT est présent dans `SharedPreferences`, on affiche `HomePage`.
/// - Sinon, on affiche la page de connexion `LoginPage`.
///
/// Il écoute aussi `AuthManager.instance.sessionInvalidated` pour
/// détecter les invalidations de session (ex: token expiré) et
/// rediriger l'utilisateur vers l'écran de connexion.
class RootRouter extends StatefulWidget {
  const RootRouter({super.key});
  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter> {
  // Listener enregistré auprès d'`AuthManager` pour réagir aux
  // invalidations de session.
  late final VoidCallback _authListener;

  /// Charge les informations minimales stockées localement.
  /// Retourne une map contenant 'jwt' et 'email' (peuvent être `null`).
  Future<Map<String, dynamic>> _loadLocal() async {
    final sp = await SharedPreferences.getInstance();
    final jwt = sp.getString('jwt');
    final email = sp.getString('email');
    // Si un JWT est présent, l'utilisateur est considéré comme
    // authentifié localement. Nous ne stockons plus le nom complet,
    // donc on renvoie uniquement le JWT et l'email.
    return {'jwt': jwt, 'email': email};
  }

  @override
  Widget build(BuildContext context) {
    // Utilise un FutureBuilder pour attendre la lecture des préférences
    // locales avant de décider quelle page afficher.
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadLocal(),
      builder: (context, snap) {
        // Tant que le Future n'est pas résolu, affiche un loader.
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snap.data!;
        // Si un JWT est présent et non vide, on navigue directement
        // vers la page d'accueil.
        if (data['jwt'] != null && data['jwt'].toString().isNotEmpty) {
          return const HomePage();
        }
        // Par défaut (non authentifié) : afficher l'écran de connexion.
        return const LoginPage.login();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Définit le callback appelé lorsque `sessionInvalidated` change.
    _authListener = () {
      if (AuthManager.instance.sessionInvalidated.value) {
        // On exécute après le frame courant pour pouvoir utiliser le
        // `BuildContext` en toute sécurité (ex: afficher un SnackBar).
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // Supprimer le JWT localement pour éviter toute réutilisation.
          final sp = await SharedPreferences.getInstance();
          await sp.remove('jwt');
          if (!mounted) return;
          // Prévenir l'utilisateur que la session a expiré, puis rediriger.
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Session expirée')));
          await Future.delayed(const Duration(milliseconds: 400));
          if (!mounted) return;
          // Naviguer vers l'écran de connexion en nettoyant la pile.
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
          // Réinitialiser le flag pour permettre de futures connexions.
          AuthManager.instance.sessionInvalidated.value = false;
        });
      }
    };
    // Enregistrer le listener auprès du gestionnaire d'authentification.
    AuthManager.instance.sessionInvalidated.addListener(_authListener);
  }

  @override
  void dispose() {
    // Nettoyer le listener pour éviter les fuites mémoire.
    AuthManager.instance.sessionInvalidated.removeListener(_authListener);
    super.dispose();
  }
}
