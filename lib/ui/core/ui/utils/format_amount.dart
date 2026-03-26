import 'package:econoris_app/config/app_config.dart';

/// Utilitaire pour formater les montants financiers de manière lisible, en ajoutant des suffixes pour les grandes valeurs (K, M, B) et en incluant la devise.
String formatAmount(double amount) {
  final sign = amount < 0 ? '-' : '+';
  final absAmount = amount.abs();
  if (absAmount >= 1e9) {
    return '$sign${(absAmount / 1e9).toStringAsFixed(2)} B${AppConfig.currency}';
  }

  if (absAmount >= 1e6) {
    return '$sign${(absAmount / 1e6).toStringAsFixed(2)} M${AppConfig.currency}';
  }

  return '$sign${absAmount.toStringAsFixed(2)} ${AppConfig.currency}';
}
