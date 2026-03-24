import 'package:econoris_app/ui/core/ui/widgets/base_app.dart';
import 'package:econoris_app/ui/home/widgets/home_body.dart';
import 'package:econoris_app/ui/operations/view_models/operation_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran d'accueil de l'application.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseApp(
      onRefresh: () async {
        await ref.read(operationViewModelProvider.notifier).refresh();
      },
      body: const HomeBody(),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Ajouter une opération',
        child: const Icon(Icons.add),
      ),
    );
  }
}
