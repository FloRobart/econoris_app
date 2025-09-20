import 'package:flutter/material.dart';

import 'navigation/app_routes.dart';
import 'pages/login_page.dart';
import 'pages/code_entry_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/placeholder_page.dart';
import 'routes/root_router.dart';
import 'config.dart';

import 'services/theme_manager.dart';

class EconorisApp extends StatelessWidget {
  const EconorisApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.instance.notifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: Config.appName,
          theme: ThemeData.light().copyWith(primaryColor: Colors.green, colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(background: Colors.white)),
          darkTheme: ThemeData.dark().copyWith(primaryColor: Colors.green),
          themeMode: mode,
          initialRoute: AppRoutes.root,
          routes: {
            AppRoutes.root: (ctx) => const RootRouter(),
            AppRoutes.login: (ctx) {
              final args = ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>?;
              final error = args?['error'] as String?;
              return LoginPage(initialError: error);
            },
            AppRoutes.home: (ctx) => const HomePage(),
            AppRoutes.profile: (ctx) => const ProfilePage(),
            AppRoutes.codeEntry: (ctx) {
              final args = ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>?;
              final email = args?['email'] as String?;
              final name = args?['name'] as String?;
              return CodeEntryPage(email: email, name: name);
            },
            AppRoutes.placeholder: (ctx) {
              final args = ModalRoute.of(ctx)!.settings.arguments as Map<String, dynamic>?;
              final title = args?['title'] as String? ?? 'Placeholder';
              return PlaceholderPage(title: title);
            },
          },
          debugShowCheckedModeBanner: false,
        );
      }
    );
  }
}
