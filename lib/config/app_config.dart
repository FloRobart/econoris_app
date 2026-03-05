import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration globale de l'application, chargée à partir du fichier .env.
class AppConfig {
  static late final String appName;
  static late final String dataUrl;
  static late final String authUrl;

  /* Charge les variables de configuration à partir du fichier .env. */
  static void load() {
    appName = 'Econoris';//dotenv.get('APP_NAME', fallback: 'Econoris');
    authUrl = 'http://192.168.1.91:26001';//dotenv.get('AUTH_URL', fallback: 'http://192.168.1.91:26001');
    dataUrl = 'http://192.168.1.91:26002';//dotenv.get('DATA_URL', fallback: 'http://192.168.1.91:26002');
  }
}
