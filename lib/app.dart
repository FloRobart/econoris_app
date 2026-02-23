import 'package:econoris_app/routing/router.dart';
import 'package:econoris_app/ui/core/themes/theme.dart';
import 'package:econoris_app/ui/core/themes/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_config.dart';

/// Racine de l'application.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeControllerProvider);
    final themeMode = themeModeAsync.value ?? ThemeMode.system;

    return MaterialApp.router(
      /* Title */
      title: AppConfig.appName,

      /* Theming */
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,

      /* Local and internationalization */
      // supportedLocales: const [Locale('fr', 'FR')],
      // locale: const Locale('fr', 'FR'),

      /* Routing */
      routerConfig: ref.watch(routerProvider),

      /* Debug */
      debugShowCheckedModeBanner: false,
    );
  }
}
