import 'package:econoris_app/domain/models/operations/create/operation_create.dart';
import 'package:econoris_app/ui/core/ui/widgets/base_app.dart';
import 'package:econoris_app/ui/operations/view_models/operation_viewmodel.dart';
import 'package:econoris_app/ui/operations/widgets/operation_body.dart';
import 'package:econoris_app/ui/operations/widgets/operation_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran d'accueil de l'application.
class OperationScreen extends ConsumerWidget {
  const OperationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Ouvre le formulaire de création d'une opération et ajoute l'opération créée à la liste.
    void openOperationCreateForm() async {
      final OperationCreate? operationCreate =
          await showModalBottomSheet<OperationCreate>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (context) => const OperationCreateForm(),
          );

      if (operationCreate != null) {
        await ref
            .read(operationViewModelProvider.notifier)
            .addOperation(operationCreate);
      }
    }

    /// Affiche l'écran des opérations
    return BaseApp(
      onRefresh: () async {
        await ref.read(operationViewModelProvider.notifier).refresh();
      },
      body: OperationBody(),

      floatingActionButton: FloatingActionButton(
        onPressed: openOperationCreateForm,
        tooltip: 'Ajouter une opération',
        child: const Icon(Icons.add),
      ),
    );
  }
}
