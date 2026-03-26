import 'package:econoris_app/config/app_config.dart';
import 'package:econoris_app/config/assets.dart';
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
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            Assets.logo_192,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Bienvenue sur ${AppConfig.appName}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 20),

                        body,
                      ],
                    ),
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
