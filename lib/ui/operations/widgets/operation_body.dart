import 'package:econoris_app/ui/operations/view_models/operation_body_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran d'accueil de l'application.
class OperationBody extends ConsumerWidget {
  const OperationBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final viewModel = ref.watch(operationBodyViewModelProvider);

    return const Center(child: Text('Operations Body'));
  }
}
