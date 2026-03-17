import 'package:econoris_app/domain/models/operations/operation.dart';
import 'package:econoris_app/ui/core/ui/operations/widgets/operations_table.dart';
import 'package:econoris_app/ui/home/view_models/home_body_viewmodel.dart';
import 'package:econoris_app/ui/home/widgets/home_stats_section.dart';
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

    return asyncOperations.when(
      data: (operations) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HomeStats(),
          const SizedBox(height: 12),

          /// Affiche une liste d'opérations récentes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: OperationsTable(operations: operations),
          ),

          const SizedBox(height: 96),
        ],
      ),
      error: (error, stackTrace) =>
          const Center(child: Text('Error loading operations')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
