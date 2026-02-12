import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration globale de l'application, chargée à partir du fichier .env.
class AppConfig {
  static late final String appName;
  static late final String dataUrl;
  static late final String authUrl;

  /* Charge les variables de configuration à partir du fichier .env. */
  static void load() {
    appName = dotenv.get('APP_NAME', fallback: 'Econoris');
    authUrl = dotenv.get('AUTH_URL', fallback: 'http://localhost:26001');
    dataUrl = dotenv.get('DATA_URL', fallback: 'http://localhost:26002');
  }
}