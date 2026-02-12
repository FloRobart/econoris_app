import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_config.dart';
import 'routing/router.dart';
import 'routing/routes.dart';
import 'ui/auth/login/widgets/code_entry_screen.dart';
import 'ui/auth/login/widgets/login_screen.dart';
import 'ui/home/widgets/home_screen.dart';
import 'ui/operations/widgets/operations_screen.dart';
import 'ui/profile/widgets/profile_screen.dart';
import 'ui/subscriptions/widgets/subscriptions_screen.dart';
import 'ui/core/themes/theme.dart';
import 'ui/core/themes/theme_controller.dart';
import 'ui/core/ui/placeholder_screen.dart';

/// Racine de l'application.
class EconorisApp extends ConsumerWidget {
  const EconorisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lecture du theme depuis Riverpod avec fallback en mode systeme.
    final themeModeAsync = ref.watch(themeControllerProvider);
    final themeMode = themeModeAsync.value ?? ThemeMode.system;

    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      initialRoute: AppRoutes.root,
      routes: {
        AppRoutes.root: (ctx) => const RootRouter(),
        AppRoutes.login: (ctx) {
          final args =
              ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>?;
          final error = args?['error'] as String?;
          return LoginPage.login(initialError: error);
        },
        AppRoutes.home: (ctx) => const HomePage(),
        AppRoutes.operations: (ctx) => const OperationsPage(),
        AppRoutes.subscriptions: (ctx) => const SubscriptionsPage(),
        AppRoutes.profile: (ctx) => const ProfilePage(),
        AppRoutes.codeEntry: (ctx) {
          final args =
              ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>?;
          final email = args?['email'] as String?;
          final name = args?['name'] as String?;
          return CodeEntryPage(email: email, name: name);
        },
        AppRoutes.placeholder: (ctx) {
          final args =
              ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>?;
          final title = args?['title'] as String? ?? 'Placeholder';
          return PlaceholderPage(title: title);
        },
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
