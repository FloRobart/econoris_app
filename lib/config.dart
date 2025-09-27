import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Les variables sont immuables une fois chargées au démarrage.
///
/// Remarque importante : il est impossible d'avoir des `const` qui proviennent
/// d'un fichier `.env` lu à l'exécution. `const` en Dart signifie valeur connue
/// à la compilation. Ici nous utilisons `late final` : les champs sont assignés
/// une seule fois (immutables ensuite) mais doivent être initialisés au runtime
/// après l'appel à `dotenv.load(...)`.
class Config {
  static late final String appName;
  static late final String econorisServer;
  static late final String floraccessServer;
  static late final String supportEmail;
  static late final String version;
  static late final String defaultLanguage;
  static late final String defaultCurrency;

  /// Charge les valeurs depuis `dotenv`. Appeler après `await dotenv.load(...)`.
  static void load() {
    appName = dotenv.get('APP_NAME', fallback: 'Econoris');
    floraccessServer = dotenv.get('FLORACCESS_SERVER', fallback: 'http://localhost:26001');
    econorisServer = dotenv.get('ECONORIS_SERVER', fallback: 'http://localhost:26002');
    supportEmail = dotenv.get('SUPPORT_EMAIL', fallback: 'Unknown');
    version = dotenv.get('APP_VERSION', fallback: 'Unknown');
    defaultLanguage = dotenv.get('DEFAULT_LANGUAGE', fallback: 'fr_FR');
    defaultCurrency = dotenv.get('DEFAULT_CURRENCY', fallback: 'EUR');
  }
}