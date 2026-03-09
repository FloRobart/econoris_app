import 'package:econoris_app/config/app_config.dart';
import 'package:econoris_app/domain/models/users/user.dart';
import 'package:econoris_app/ui/core/themes/theme.dart';
import 'package:econoris_app/ui/core/ui/utils/format_date.dart';
import 'package:econoris_app/ui/core/ui/widgets/base_app.dart';
import 'package:econoris_app/ui/core/ui/widgets/card_container.dart';
import 'package:econoris_app/ui/profile/view_models/profile_screen_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Écran de profil de l'application.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(profileScreenViewModelProvider);
    final currentUserAsync = ref.watch(profileCurrentUserProvider);
    final ThemeData theme = Theme.of(context);

    return BaseApp(
      body: currentUserAsync.when(
        data: (user) {
          viewModel.setUser = user;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header card with avatar and basic info
                CardContainer(
                  child: Row(
                    children: [
                      /// User avatar with initials
                      CircleAvatar(
                        radius: 34,
                        child: Text(
                          viewModel.getUserInitial,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// User info (pseudo and email)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Pseudo
                            Text(
                              viewModel.getUserPseudo,
                              style: theme.textTheme.titleMedium,
                            ),

                            const SizedBox(height: 4),

                            /// Email
                            Text(
                              viewModel.getUserEmail,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /// Account status section
                CardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statut du compte',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(height: 12),

                      /// Connection status
                      Row(
                        children: [
                          Icon(
                            Icons.link,
                            color: viewModel.isUserConnected
                                ? AppTheme.success
                                : AppTheme.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${!viewModel.isUserConnected ? 'Non ' : ''}Connecté',
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// Email verification status
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            color: viewModel.isUserEmailVerified
                                ? AppTheme.success
                                : AppTheme.warning,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Email ${!viewModel.isUserEmailVerified ? 'non ' : ''}vérifié',
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// Account creation date
                      Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(
                            'Créé le : ${formatDate(viewModel.getUserCreatedAt, customFormat: 'EEEE dd MMMM yyyy') ?? 'Inconnu'}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// Logout section
                CardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Déconnexion',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(height: 12),

                      /// Logout button
                      Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: AppTheme.error,
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: viewModel.logout,
                            child: const Text('Déconnexion de cet appareil'),
                          ),
                        ],
                      ),

                      /// Logout all button
                      Row(
                        children: [
                          Icon(
                            Icons.exit_to_app,
                            color: AppTheme.error,
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: viewModel.logoutAll,
                            child: const Text('Déconnexion de tous les appareils'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: Text(
                    'Version : ${AppConfig.appVersion}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),

                const SizedBox(height: 36),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Impossible de charger votre profil.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}
