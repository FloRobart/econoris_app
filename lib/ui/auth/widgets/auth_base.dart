import 'package:flutter/material.dart';

class AuthBase extends StatelessWidget {
  const AuthBase({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.15),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(24),

                    /* Affichage du contenu */
                    child: body,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
