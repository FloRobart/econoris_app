// Flutter and state management imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Configuration and routing
import 'config/app_config.dart';
import 'routing/routes.dart';

// Pages / écrans de l'application
// Thèmes et contrôleur de thème
import 'ui/core/themes/theme.dart';
import 'ui/core/themes/theme_controller.dart';

// Table de routage centralisée
import 'routing/router.dart';

/* Widget racine de l'application.
- Fournit le MaterialApp avec les thèmes, la configuration de navigation et les routes.
- Utilise le ThemeControllerProvider pour appliquer le thème choisi par l'utilisateur.
- La navigation initiale est gérée par RootRouter qui décide d'afficher HomePage ou LoginPage selon la présence d'un JWT en local.
- Les routes sont définies dans AppRoutes et mappées à des widgets dans la table `routes` du MaterialApp.
- Le RootRouter écoute aussi les événements d'invalidation de session pour rediriger vers la page de connexion si le token expire ou devient invalide.
*/
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /* Récupère le thème actuel depuis le ThemeControllerProvider */
    final themeModeAsync = ref.watch(themeControllerProvider);
    final themeMode = themeModeAsync.value ?? ThemeMode.system;

    /* Fournit le MaterialApp avec les thèmes, la configuration de navigation et les routes. */
    return MaterialApp(
      /* Titre affiché dans le multitâche / switcher */
      title: AppConfig.appName,

      /* Thèmes clair et sombre fournis par `AppTheme`. */
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,

      /* Route initiale */
      initialRoute: AppRoutes.root,

      /* Table de routage centralisée dans router.dart */
      routes: buildAppRoutes(),

      /* Désactive la bannière de debug en mode debug. */
      debugShowCheckedModeBanner: false,
    );
  }
}
