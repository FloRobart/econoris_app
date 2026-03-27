/// Classe de constantes utilisées dans l'application pour centraliser les paramètres et les clés de configuration.
class Constantes {
  /* Séléction des opérations ou des abonnements dans les listes d'accueil. */
  static const bool isOperationSelected = true;
  static const bool isSubscriptionSelected = true;

  /* Seuils et paramètres utilisés pour la détection des salaires dans les opérations. */
  static const int salaryWindowSafetyMarginDays = 4;

  /* Clés utilisées pour la sauvegarde du brouillon de création d'opération dans les SharedPreferences. */
  static const draftOperationAmountKey = 'draft_operation_amount_key';
  static const draftOperationLabelKey = 'draft_operation_label_key';
  static const draftOperationDateKey = 'draft_operation_date_key';
  static const draftOperationCategoryKey = 'draft_operation_category_key';
  static const draftOperationIsExpenseKey = 'draft_operation_is_expense_key';

  /* Clés utilisées pour la sauvegarde du brouillon de création d'abonnement dans les SharedPreferences. */
  static const draftSubscriptionAmountKey = 'draft_subscription_amount_key';
  static const draftSubscriptionLabelKey = 'draft_subscription_label_key';
  static const draftSubscriptionDateKey = 'draft_subscription_date_key';
  static const draftSubscriptionCategoryKey = 'draft_subscription_category_key';
  static const draftSubscriptionIsExpenseKey =
      'draft_subscription_is_expense_key';

  /* Récurrences disponibles pour les abonnements. */
  static const List<String> subscriptionRecurrences = [
    'mensuel',
    'trimestriel',
    'semestriel',
    'annuel',
  ];

  /* Liste des catégories d'opérations disponibles dans l'application. (Temporaire) */
  static const List<String> operationCategories = [
    /* Achats et shopping */
    'Courses',
    'Restaurants',
    'Vêtements',
    'Cadeaux',
    'Animaux',
    'Enfants',

    /* Investissements et revenus */
    'Salaire',
    'Epargne',
    'Bourses',
    'Cryptomonnaies',
    'Remboursements',
    'Dividendes',

    /* Loisirs et vacances */
    'Sports',
    'Cinémas et culture',
    'Bars',
    'Loisirs'
    'Esthétique',
    'Multimédia',
    'Vacances',

    /* Logement et charges */
    'Loyer',
    'Eau, Electricité, Gaz',
    'Internet, téléphone',
    'Travaux',
    'Meubles',
    'Electroménager',
    'Prêt immobilier',

    /* Santé */
    'Santé',

    /* Transports */
    'Transports en commun',
    'Voiture',
    'Moto',
    'Carburant',
    'Parking',
    'Péage',
    'Entretien véhicule',

    /* Impôts, taxes et frais */
    'Frais bancaires',
    'Impôts',
    'Taxes',
    'Prêts et crédits',
    'Amendes',

    /* Matériel et équipement */
    'Ordinateur',
    'Téléphone',
    'Montres',
    'Bijoux',
    'Accessoires high-tech',

    /* Travail et études */
    'Prêts étudiants',
    'Dépenses professionnelles',
    'Formations',
    'Matériel scolaire',
  ];
}
