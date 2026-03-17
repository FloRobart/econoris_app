import 'package:econoris_app/ui/core/ui/widgets/header.dart';
import 'package:econoris_app/ui/core/ui/widgets/app_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Widget d'en-tête pour les écrans de l'application.
class BaseApp extends StatelessWidget {
  const BaseApp({
    super.key,
    required this.body,
    this.onRefresh,
    this.onAddButtonPressed,
    this.addButtonTooltip,
  });

  final Widget body;
  final Future<void> Function()? onRefresh;
  final void Function()? onAddButtonPressed;
  final String? addButtonTooltip;

  /// Rafraîchit le contenu de l'écran. Si une fonction de rafraîchissement personnalisée est fournie, elle sera utilisée. Sinon, la page sera simplement rafraîchie.
  Future<void> _refresh(BuildContext context) async {
    if (onRefresh != null) {
      await onRefresh!();
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return;
    }

    GoRouter.of(context).refresh();
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* En-tête */
      appBar: Header(),

      /* Contenu principal */
      body: RefreshIndicator(
        onRefresh: () => _refresh(context),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: SizedBox(width: double.infinity, child: body),
              ),
            );
          },
        ),
      ),

      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: onAddButtonPressed,
            tooltip: addButtonTooltip,
            child: const Icon(Icons.add),
          ),

          const SizedBox(height: 8, width: 8),

          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: onAddButtonPressed,
            tooltip: addButtonTooltip,
            child: Text('Ajouter une opération'),
          ),
        ],
      ),

      /* Navigation */
      bottomNavigationBar: const AppNavigationBar(),
    );
  }
}
