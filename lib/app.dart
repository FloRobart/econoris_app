// Flutter and state management imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Configuration and routing
import 'config/app_config.dart';
import 'routing/routes.dart';

// Pages / écrans de l'application
import 'ui/auth/login/widgets/code_entry_screen.dart';
import 'ui/auth/login/widgets/login_screen.dart';
import 'ui/home/widgets/home_screen.dart';
import 'ui/operations/widgets/operations_screen.dart';
import 'ui/profile/widgets/profile_screen.dart';
import 'ui/subscriptions/widgets/subscriptions_screen.dart';

// Thèmes et contrôleur de thème
import 'ui/core/themes/theme.dart';
import 'ui/core/themes/theme_controller.dart';

// Écran générique de repli (placeholder)
import 'ui/core/ui/placeholder_screen.dart';

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

      /* Table de routage : mappe les noms de routes à des widgets. */
      routes: {
        /* La route racine (/) est gérée par RootRouter qui décide d'afficher HomePage ou LoginPage selon la présence d'un JWT en local. */
        AppRoutes.root: (context) => const HomePage(),

        /* Route de connexion : peut recevoir un argument `error` pour afficher un message d'erreur initial. */
        AppRoutes.login: (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          final error = args?['error'] as String?;
          debugPrint('Navigating to LoginPage with error: $error');
          return LoginPage(key: const Key('LoginPage'));
        },

        /* Écrans principaux simples sans arguments. */
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.operations: (context) => const OperationsPage(),
        AppRoutes.subscriptions: (context) => const SubscriptionsPage(),
        AppRoutes.profile: (context) => const ProfilePage(),

        /* Écran pour saisie de code : attend `email` et `name` optionnels. */
        AppRoutes.codeEntry: (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          final email = args?['email'] as String?;
          final name = args?['name'] as String?;
          return CodeEntryPage(email: email, name: name);
        },

        /* Page générique de placeholder : permet d'afficher un titre. */
        AppRoutes.placeholder: (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          final title = args?['title'] as String? ?? 'Placeholder';
          return PlaceholderPage(title: title);
        },
      },

      /* Désactive la bannière de debug en mode debug. */
      debugShowCheckedModeBanner: false,
    );
  }
}
