import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app/econoris_app.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from .env (falls back to defaults in Config)
  await dotenv.load(fileName: '.env');

  // Initialize immutable Config values from dotenv
  Config.load();

  // Initialize intl locale data for formatting dates/numbers (French)
  await initializeDateFormatting('fr_FR');
  Intl.defaultLocale = 'fr_FR';
  runApp(const ProviderScope(child: EconorisApp()));
}
