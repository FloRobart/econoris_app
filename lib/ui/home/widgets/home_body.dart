import 'package:econoris_app/domain/models/operations/operation.dart';
import 'package:econoris_app/ui/core/ui/operations/widgets/operation_management_index.dart';
import 'package:econoris_app/ui/core/ui/operations/widgets/operation_monthly_stats.dart';
import 'package:econoris_app/ui/core/ui/operations/widgets/operations_list.dart';
import 'package:econoris_app/ui/home/view_models/home_body_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Corp de l'écran d'accueil de l'application.
class HomeBody extends ConsumerWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Operation>> asyncOperations = ref.watch(
      homeOperationsProvider,
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

        const SizedBox(height: 12),

        /// Affiche une liste d'opérations récentes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: asyncOperations.when(
            data: (operations) => OperationsList(operations: operations),
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
