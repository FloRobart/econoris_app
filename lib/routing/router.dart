
import 'package:econoris_app/routing/routes.dart';
import 'package:econoris_app/ui/auth/login/widgets/code_entry_screen.dart';
import 'package:econoris_app/ui/auth/login/widgets/login_screen.dart';
import 'package:econoris_app/ui/core/ui/placeholder_screen.dart';
import 'package:econoris_app/ui/home/widgets/home_screen.dart';
import 'package:econoris_app/ui/operations/widgets/operations_legacy_screen.dart';
import 'package:econoris_app/ui/profile/widgets/profile_screen.dart';
import 'package:econoris_app/ui/subscriptions/widgets/subscriptions_screen.dart';
import 'package:flutter/material.dart';
import 'package:econoris_app/data/services/auth_manager.dart';


/// Retourne la table de routage de l'application.
Map<String, WidgetBuilder> buildAppRoutes() {
	return {
		/* La route racine (/) est gérée par RootRouter qui décide d'afficher HomePage ou LoginPage selon la présence d'un JWT en local. */
		AppRoutes.root: (context) => const RootRouter(),

		/* Route de connexion : peut recevoir un argument `error` pour afficher un message d'erreur initial. */
		AppRoutes.login: (context) {
			final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
			final error = args?['error'] as String?;
			debugPrint('Navigating to LoginPage with error: $error');
			return LoginPage(key: const Key('LoginPage'));
		},

		/* Écrans principaux simples sans arguments. */
		AppRoutes.home: (context) {
      // if user is not authenticated, RootRouter will redirect to login, so we can assume user is authenticated here
      return HomePage();
    },
		AppRoutes.operations: (context) => const OperationsPage(),
		AppRoutes.subscriptions: (context) => const SubscriptionsPage(),
		AppRoutes.profile: (context) => const ProfilePage(),

		/* Écran pour saisie de code : attend `email` et `name` optionnels. */
		AppRoutes.codeEntry: (context) {
			final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
			final email = args?['email'] as String?;
			final name = args?['name'] as String?;
			return CodeEntryPage(email: email, name: name);
		},

		/* Page générique de placeholder : permet d'afficher un titre. */
		AppRoutes.placeholder: (context) {
			final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
			final title = args?['title'] as String? ?? 'Placeholder';
			return PlaceholderPage(title: title);
		},
	};
}

/// Widget qui décide de la route initiale en fonction de la présence d'un JWT.
class RootRouter extends StatelessWidget {
	const RootRouter({super.key});

	@override
	Widget build(BuildContext context) {
		return FutureBuilder<String?>(
			future: AuthManager.instance.loadJwt(),
			builder: (context, snapshot) {
				if (snapshot.connectionState == ConnectionState.waiting) {
					return const Scaffold(
						body: Center(child: CircularProgressIndicator()),
					);
				}

				final hasJwt = snapshot.data != null && snapshot.data!.isNotEmpty;

				WidgetsBinding.instance.addPostFrameCallback((_) {
					if (hasJwt) {
						Navigator.of(context).pushReplacementNamed(AppRoutes.home);
					} else {
						Navigator.of(context).pushReplacementNamed(AppRoutes.login);
					}
				});

				return const SizedBox.shrink();
			},
		);
	}
}
