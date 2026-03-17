import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran d'accueil de l'application.
class OperationBody extends ConsumerWidget {
  const OperationBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Operations Body'));
  }
}
