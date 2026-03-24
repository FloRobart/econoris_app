import 'package:econoris_app/domain/models/operations/operation.dart';
import 'package:econoris_app/ui/core/themes/theme.dart';
import 'package:econoris_app/ui/core/ui/operations/widgets/operation_management_index.dart';
import 'package:econoris_app/ui/core/ui/operations/widgets/operation_monthly_stats.dart';
import 'package:econoris_app/ui/core/ui/operations/widgets/operations_list.dart';
import 'package:econoris_app/ui/home/view_models/home_body_viewmodel.dart';
import 'package:econoris_app/ui/operations/view_models/operation_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Corp de l'écran d'accueil de l'application.
class HomeBody extends ConsumerWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final AsyncValue<List<Operation>> asyncOperations = ref.watch(
      operationViewModelProvider,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Affiche l'index de gestion d'argent
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: const OperationManagementIndex(),
        ),

        const SizedBox(height: 12),

        /// Affiche des statistiques mensuelles sur les opérations
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: const OperationMonthlyStats(),
        ),

        const SizedBox(height: 32),

        /// Affiche un titre pour les opérations à venir
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hourglass_empty_outlined,
                  color: AppTheme.infoColor,
                  size: (theme.textTheme.titleLarge?.fontSize ?? 22) + 2,
                ),
                const SizedBox(width: 8),
                Text(
                  'Opérations à venir',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 22),

        /// Affiche une liste d'opérations à venir
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: asyncOperations.when(
            data: (operations) {
              HomeBodyViewmodel homeViewmodel = HomeBodyViewmodel(operations);
              return OperationsList(
                operations: homeViewmodel.upComingOperations,
              );
            },
            error: (error, stackTrace) =>
                const Center(child: Text('Error loading operations')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),

        const SizedBox(height: 32),

        /// Affiche un titre pour les opérations récentes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history_rounded,
                  color: AppTheme.successColor,
                  size: (theme.textTheme.titleLarge?.fontSize ?? 22) + 2,
                ),
                const SizedBox(width: 8),
                Text(
                  'Opérations récentes',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 22),

        /// Affiche une liste d'opérations récentes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: asyncOperations.when(
            data: (operations) {
              HomeBodyViewmodel homeViewmodel = HomeBodyViewmodel(operations);
              return OperationsList(operations: homeViewmodel.pastOperations);
            },
            error: (error, stackTrace) =>
                const Center(child: Text('Error loading operations')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),

        const SizedBox(height: 96),
      ],
    );
  }
}
