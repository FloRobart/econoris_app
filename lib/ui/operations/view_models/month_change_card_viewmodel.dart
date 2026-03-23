import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider pour le [MonthChangeCardViewmodel], permettant de l'injecter dans le widget [MonthChangeCard].
final monthChangeCardViewModelProvider =
    NotifierProvider<MonthChangeCardViewmodel, MonthChangeCardState>(
      MonthChangeCardViewmodel.new,
    );

/// Viewmodel pour le [MonthChangeCard], gérant la logique de changement de mois.
class MonthChangeCardViewmodel extends Notifier<MonthChangeCardState> {
  @override
  MonthChangeCardState build() {
    final now = DateTime.now();
    return MonthChangeCardState(
      currentMonth: DateTime(now.year, now.month, 1),
      monthOffset: 0,
    );
  }

  /// Permet de passer au mois précédent en décrémentant l'offset de mois.
  void previousMonth() {
    _setMonthOffset(state.monthOffset - 1);
  }

  /// Permet de passer au mois suivant en incrémentant l'offset de mois.
  void nextMonth() {
    _setMonthOffset(state.monthOffset + 1);
  }

  /// Met à jour l'offset de mois et calcule le nouveau mois courant en fonction de cet offset.
  void _setMonthOffset(int newOffset) {
    final now = DateTime.now();
    state = state.copyWith(
      monthOffset: newOffset,
      currentMonth: DateTime(now.year, now.month + newOffset, 1),
    );
  }
}

/// Etat du [MonthChangeCardViewmodel].
class MonthChangeCardState {
  const MonthChangeCardState({
    required this.currentMonth,
    required this.monthOffset,
  });

  final DateTime currentMonth;
  final int monthOffset;

  /// Permet de créer une copie de l'état actuel en modifiant uniquement les champs spécifiés.
  MonthChangeCardState copyWith({DateTime? currentMonth, int? monthOffset}) {
    return MonthChangeCardState(
      currentMonth: currentMonth ?? this.currentMonth,
      monthOffset: monthOffset ?? this.monthOffset,
    );
  }
}
