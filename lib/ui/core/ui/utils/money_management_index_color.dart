import 'package:flutter/material.dart';

/// Utilitaire pour déterminer la couleur de l'index de gestion d'argent en fonction de sa valeur.
Color getMoneyManagementIndexColor(double moneyManagementIndex) {
  if (moneyManagementIndex == 0) {
    return Colors.grey;
  }
  if (moneyManagementIndex < 0.8) {
    return Colors.red;
  }
  if (moneyManagementIndex < 1.0) {
    return Colors.orange;
  }
  if (moneyManagementIndex < 1.2) {
    return Colors.amberAccent;
  }
  if (moneyManagementIndex < 1.5) {
    return Colors.lightGreen;
  }
  return Colors.teal;
}
