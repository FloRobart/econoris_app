import 'package:econoris_app/data/services/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app.dart';
import 'config/app_config.dart';

void main() async {
  /* Assure que les widgets Flutter sont initialisés avant d'exécuter le reste du code */
  WidgetsFlutterBinding.ensureInitialized();

  /* Charge les variables d'environnement */
  await dotenv.load(fileName: '.env');

  /* Charge la configuration de l'application */
  AppConfig.load();

  /* Charge le JWT stocké localement (s'il existe) pour maintenir la session de l'utilisateur */
  AuthManager.instance.loadJwt();

  /* Initialise les paramètres régionaux pour la localisation en français */
  await initializeDateFormatting('fr_FR');
  Intl.defaultLocale = 'fr_FR';

  /* Démarre l'application avec le ProviderScope pour la gestion de l'état */
  runApp(const ProviderScope(child: App()));
}
