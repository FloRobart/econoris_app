import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'config.dart';
import 'services/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from .env (falls back to defaults in Config)
  await dotenv.load(fileName: '.env');

  // Initialize immutable Config values from dotenv
  Config.load();

  await ThemeManager.instance.load();
  // initialize notifier with loaded value
  ThemeManager.instance.notifier.value = ThemeManager.instance.mode;
  // Initialize intl locale data for formatting dates/numbers (French)
  await initializeDateFormatting('fr_FR');
  Intl.defaultLocale = 'fr_FR';
  runApp(const EconorisApp());
}