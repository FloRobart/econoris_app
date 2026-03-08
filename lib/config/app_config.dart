import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Configuration globale de l'application, chargée à partir du fichier .env.
class AppConfig {
  static late final String appName;
  static late final String dataUrl;
  static late final String authUrl;
  static String appVersion = 'Inconnu';

  /* Charge les variables de configuration à partir du fichier .env. */
  static void load() {
    appName = 'Econoris';//dotenv.get('APP_NAME', fallback: 'Econoris');
    authUrl = 'http://192.168.1.91:26001';//dotenv.get('AUTH_URL', fallback: 'http://192.168.1.91:26001');
    dataUrl = 'http://192.168.1.91:26002';//dotenv.get('DATA_URL', fallback: 'http://192.168.1.91:26002');

    /// Récupère la version de l'application à partir des informations du package.
    PackageInfo.fromPlatform().then(
      (packageInfo) => appVersion = '${packageInfo.version}+${packageInfo.buildNumber}',
    );
  }
}
