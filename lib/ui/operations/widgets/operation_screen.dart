import 'package:econoris_app/ui/core/ui/widgets/base_app.dart';
import 'package:econoris_app/ui/operations/widgets/operation_body.dart';
import 'package:flutter/material.dart';

/// Écran d'accueil de l'application.
class OperationScreen extends StatelessWidget {
  const OperationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseApp(body: OperationBody());
  }
}
