import 'package:flutter/material.dart';

/// Utilitaire pour déterminer la couleur à utiliser pour afficher les dépenses possibles en fonction de leur montant.
Color getPossibleExpenseColor(double amount) {
  if (amount < 0) { return Colors.red; }
  if (amount < 100) { return Colors.orange; }
  if (amount < 200) { return Colors.amberAccent; }
  return Colors.green;
}
