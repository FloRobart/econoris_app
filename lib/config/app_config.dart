import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Les variables sont immuables une fois chargees au demarrage.
///
/// Remarque importante : il est impossible d'avoir des `const` qui proviennent
/// d'un fichier `.env` lu a l'execution. `const` en Dart signifie valeur connue
/// a la compilation. Ici nous utilisons `late final` : les champs sont assignes
/// une seule fois (immutables ensuite) mais doivent etre initialises au runtime
/// apres l'appel a `dotenv.load(...)`.
class AppConfig {
  static late final String appName;
  static late final String econorisServer;
  static late final String floraccessServer;
  static late final String defaultLanguage;
  static late final String defaultCurrency;

  /// Charge les valeurs depuis `dotenv`. Appeler apres `await dotenv.load(...)`.
  static void load() {
    appName = dotenv.get('APP_NAME', fallback: 'Econoris');
    floraccessServer =
        dotenv.get('FLORACCESS_SERVER', fallback: 'http://localhost:26001');
    econorisServer =
        dotenv.get('ECONORIS_SERVER', fallback: 'http://localhost:26002');
    defaultLanguage = dotenv.get('DEFAULT_LANGUAGE', fallback: 'fr_FR');
    defaultCurrency = dotenv.get('DEFAULT_CURRENCY', fallback: 'EUR');
  }
}
