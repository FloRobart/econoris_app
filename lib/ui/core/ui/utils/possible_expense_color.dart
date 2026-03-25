import 'package:flutter/material.dart';

/// Utilitaire pour déterminer la couleur à utiliser pour afficher les dépenses possibles en fonction de leur montant.
Color getPossibleExpenseColor(double percentage) {
  if (percentage <= 3) {
    return Colors.red;
  }
  if (percentage < 8) {
    return Colors.orange;
  }
  if (percentage < 12) {
    return Colors.amberAccent;
  }
  return Colors.green;
}
