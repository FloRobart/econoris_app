import 'package:econoris_app/ui/core/ui/operations/view_models/operation_stats_viewmodel.dart';
import 'package:econoris_app/ui/core/ui/operations/view_models/operation_management_index_viewmodel.dart';
import 'package:econoris_app/ui/core/ui/utils/format_date.dart';
import 'package:econoris_app/ui/core/ui/utils/money_management_index_color.dart';
import 'package:econoris_app/ui/core/ui/utils/money_management_index_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OperationManagementIndex extends StatelessWidget {
  const OperationManagementIndex({super.key});

  @override
  Widget build(BuildContext context) {
    void showManagementIndexHelper() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Comment fonctionne l\'indice de gestion d\'argent ?',
          ),
          content: const Text(
            'L\'indice de gestion d\'argent est une mesure qui évalue la performance de votre gestion financière.\n\nGlobalement, plus l\'indice est élevé, meilleure est votre gestion de l\'argent.\n\nSi votre indice est à 100 alors vous dépensez exactement ce que vous gagnez, si il est à 50 alors vous dépensez deux fois plus que ce que vous gagnez, et si il est à 200 alors vous gagnez deux fois plus que ce que vous dépensez.\n\nAttention pour le moment l\'indice ne prend pas en compte l\'épargne, ni les investissements, se qui peux faire baisser votre indice alors que votre situation financière s\'améliore. C\'est une fonctionnalité que nous prévoyons d\'ajouter dans le futur.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _MoneyManagementIndexIcons(22),
                        const SizedBox(width: 8),
                        const Text('Indice de gestion d\'argent'),
                        IconButton(
                          onPressed: showManagementIndexHelper,
                          icon: const Icon(Icons.info_outline, size: 18),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Informations',
                        ),
                      ],
                    ),

                    const _MoneyManagementIndexDate(),

                    const SizedBox(height: 8),

                    const _MoneyManagementIndexValue(),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _MoneyManagementIndexIcons(36),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget pour afficher la valeur de l'indice de gestion d'argent, avec une couleur dynamique en fonction de sa valeur.
class _MoneyManagementIndexValue extends ConsumerWidget {
  const _MoneyManagementIndexValue();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncViewModel = ref.watch(
      operationManagementIndexViewmodelProvider,
    );

    final indexColor = getMoneyManagementIndexColor(
      asyncViewModel
              .whenData((viewmodel) => viewmodel.moneyManagementIndex)
              .value ??
          0,
    );

    final indexText = getMoneyManagementIndexText(
      asyncViewModel
              .whenData((viewmodel) => viewmodel.moneyManagementIndex)
              .value ??
          0,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text:
                asyncViewModel
                    .whenData((viewmodel) => viewmodel.moneyManagementIndexPercentage)
                    .value
                    ?.toStringAsFixed(0) ??
                '0',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: indexColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: ' $indexText',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: indexColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget pour afficher les icônes de l'indice de gestion d'argent, avec une couleur dynamique en fonction de sa valeur.
class _MoneyManagementIndexIcons extends ConsumerWidget {
  const _MoneyManagementIndexIcons(this.size);

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncManagementIndex = ref.watch(
      operationManagementIndexViewmodelProvider,
    );

    return Icon(
      Icons.speed_outlined,
      size: size,
      color: getMoneyManagementIndexColor(
        asyncManagementIndex
                .whenData((viewmodel) => viewmodel.moneyManagementIndex)
                .value ??
            0,
      ),
    );
  }
}

/// Widget pour afficher les dates du mois financier correspondant à l'indice de gestion d'argent
class _MoneyManagementIndexDate extends ConsumerWidget {
  const _MoneyManagementIndexDate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStartMonthDate = ref.watch(
      operationStatsProvider.select(
        (asyncStats) => asyncStats.whenData((stats) => stats.startMonthDate),
      ),
    );

    final asyncEndMonthDate = ref.watch(
      operationStatsProvider.select(
        (asyncStats) => asyncStats.whenData((stats) => stats.endMonthDate),
      ),
    );

    final startMonthDate = asyncStartMonthDate.when(
      data: (startMonthDate) =>
          formatDate(startMonthDate, customFormat: 'dd MMMM yyyy') ??
          'Mois inconnu',
      loading: () => '...',
      error: (error, stackTrace) => 'Mois inconnu',
    );

    final endMonthDate = asyncEndMonthDate.when(
      data: (endMonthDate) =>
          formatDate(endMonthDate, customFormat: 'dd MMMM yyyy') ??
          'Mois inconnu',
      loading: () => '...',
      error: (error, stackTrace) => 'Mois inconnu',
    );

    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'Du '),
          TextSpan(
            text: startMonthDate,
            style:
                Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold) ??
                TextStyle(fontWeight: FontWeight.bold),
          ),
          const TextSpan(text: ' au '),
          TextSpan(
            text: endMonthDate,
            style:
                Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold) ??
                TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
