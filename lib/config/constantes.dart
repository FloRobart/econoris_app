class Constantes {
  static const bool isOperationSelected = true;
  static const bool isSubscriptionSelected = true;

  static const List<String> operationCategories = [
    'Alimentation',
    'Transport',
    'Logement',
    'Sante',
    'Loisirs',
    'Abonnements',
    'Salaire',
    'Investissements',
    'Autres',
  ];

  static const int salaryWindowSafetyMarginDays = 4;
  static const double salarySimilarityRatio = 0.8;
  static const int salaryDistanceThresholdDays = 26;
}
