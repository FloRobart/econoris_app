import 'package:econoris_app/routing/router.dart';
import 'package:econoris_app/ui/core/themes/theme.dart';
import 'package:econoris_app/ui/core/themes/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_config.dart';

/// Racine de l'application.
class App extends ConsumerWidget {
  const App({super.key});

  Locale _buildLocaleFromConfig(String localeConfig) {
    final normalized = localeConfig.trim().replaceAll('-', '_');
    final parts = normalized.split('_');
    final languageCode = parts.isNotEmpty && parts.first.isNotEmpty
        ? parts.first.toLowerCase()
        : 'fr';
    final countryCode = parts.length > 1 && parts[1].isNotEmpty
        ? parts[1].toUpperCase()
        : null;
    return Locale(languageCode, countryCode);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeControllerProvider);
    final themeMode = themeModeAsync.value ?? ThemeMode.system;
    final appLocale = _buildLocaleFromConfig(AppConfig.localization);

    return MaterialApp.router(
      /* Title */
      title: AppConfig.appName,

      /* Localization */
      locale: appLocale,
      supportedLocales: [appLocale],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      /* Theming */
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,

      /* Routing */
      routerConfig: ref.watch(routerProvider),

      /* Debug */
      debugShowCheckedModeBanner: false,
    );
  }
}
