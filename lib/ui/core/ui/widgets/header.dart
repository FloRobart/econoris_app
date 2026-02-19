import 'package:econoris_app/config/app_config.dart';
import 'package:econoris_app/config/assets.dart';
import 'package:econoris_app/domain/models/auth/user/user.dart';
import 'package:econoris_app/routing/routes.dart';
import 'package:econoris_app/ui/core/themes/theme.dart';
import 'package:flutter/material.dart';

/// Widget d'en-tête (AppBar) pour les écrans de l'application.
class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key, required this.user});

  final User user;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /* réinitialiser la navigation puis rediriger vers home page */
  void _onPressedHomeButton(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == AppRoutes.home) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
  }

  /* Redirige vers la page de profil si l'utilisateur n'est pas déjà sur cette page */
  void _onPressedProfileButton(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == AppRoutes.profile) {
      return;
    }

    Navigator.pushNamed(context, AppRoutes.profile);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _onPressedHomeButton(context),
                icon: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Image.asset(Assets.logo_512, height: 40),
              ),
                label: Text(
                AppConfig.appName,
                style: TextStyle(
                  fontSize: AppTheme.fontSizes[AppFontSize.xlarge],
                  fontWeight: FontWeight.w500,
                ),
              ),
              ),
              
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _onPressedProfileButton(context),
                icon: const Icon(Icons.person),
                label: Text(
                  user.pseudo,
                  style: TextStyle(
                    fontSize: AppTheme.fontSizes[AppFontSize.medium],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
