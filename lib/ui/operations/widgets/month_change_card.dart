import 'package:econoris_app/ui/core/ui/utils/format_date.dart';
import 'package:econoris_app/ui/operations/view_models/month_change_card_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MonthChangeCard extends ConsumerWidget {
  const MonthChangeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(monthChangeCardViewModelProvider);
    final viewModel = ref.read(monthChangeCardViewModelProvider.notifier);

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Bouton pour aller au mois précédent
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  viewModel.previousMonth();
                },
              ),

              /// Affiche le mois et l'année courants
              Text(
                formatDate(
                      state.currentMonth,
                      customFormat: 'MMMM yyyy',
                    )?.toUpperCase() ??
                    DateFormat(
                      'MMMM yyyy',
                    ).format(DateTime.now()).toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge,
              ),

              /// Bouton pour aller au mois suivant
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  viewModel.nextMonth();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
