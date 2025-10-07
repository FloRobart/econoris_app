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
          theme: ThemeData.light().copyWith(
      primaryColor: Colors.amber,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber)
        .copyWith(surface: Colors.white, primary: Colors.amber, onPrimary: Colors.white),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBB80A),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                elevation: 2,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Color(0xFFFBB80A)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFFFBB80A),
              foregroundColor: Colors.black,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
      primaryColor: Colors.amber.shade700,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber, brightness: Brightness.dark)
        .copyWith(primary: Colors.amber.shade700, onPrimary: Colors.white),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBB80A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                elevation: 2,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFFBB80A)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFFFBB80A),
              foregroundColor: Colors.white,
            ),
          ),
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
