/// Utilitaire pour déterminer le texte de l'index de gestion d'argent en fonction de sa valeur.
String getMoneyManagementIndexText(double moneyManagementIndex) {
  if (moneyManagementIndex == 0) {
    return 'Vous n\'avez aucun revenu';
  }
  if (moneyManagementIndex < 0.8) {
    return 'Mauvais';
  }
  if (moneyManagementIndex < 1.0) {
    return 'Moyen';
  }
  if (moneyManagementIndex < 1.2) {
    return 'Bon';
  }
  if (moneyManagementIndex < 1.5) {
    return 'Très bon';
  }
  return 'Excellente';
}
