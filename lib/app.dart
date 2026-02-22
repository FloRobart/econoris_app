import 'package:econoris_app/ui/auth/widgets/login_screen.dart';
import 'package:econoris_app/ui/core/themes/theme.dart';
import 'package:econoris_app/ui/core/themes/theme_controller.dart';
import 'package:econoris_app/ui/home/widgets/home_screen.dart';
import 'package:econoris_app/ui/operations/widgets/operations_screen.dart';
import 'package:econoris_app/ui/profile/widgets/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_config.dart';
import 'routing/routes.dart';

/// Racine de l'application.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeControllerProvider);
    final themeMode = themeModeAsync.value ?? ThemeMode.system;

    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      initialRoute: AppRoutes.home,
      routes: {
        /* Home */
        AppRoutes.home: (context) => const HomeScreen(),

        /* Auth */
        AppRoutes.login: (context) => const LoginScreen(),
        // AppRoutes.codeEntry: (context) => const CodeEntryPage(),

        /* Profile */
        AppRoutes.profile: (context) => const ProfileScreen(),

        // /* Operations */
        AppRoutes.operations: (context) => const OperationsScreen(),

        // /* Subscriptions */
        // AppRoutes.subscriptions: (context) => const SubscriptionsPage(),

        /* Placeholder */
        // AppRoutes.placeholder: (context) {
        //   final args =
        //       ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        //   final title = args?['title'] as String? ?? 'Placeholder';
        //   return PlaceholderPage(title: title);
        // },
      },

      debugShowCheckedModeBanner: false,
    );
  }
}
