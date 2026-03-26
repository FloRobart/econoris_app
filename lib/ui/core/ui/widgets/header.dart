import 'package:econoris_app/config/app_config.dart';
import 'package:econoris_app/config/assets.dart';
import 'package:econoris_app/routing/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:econoris_app/ui/core/themes/theme.dart';
import 'package:flutter/material.dart';

/// Widget d'en-tête (AppBar) pour les écrans de l'application.
class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /* réinitialiser la navigation puis rediriger vers home page */
  void _onPressedHomeButton(BuildContext context) {
    final String currentRoute = GoRouter.of(context).state.matchedLocation;
    if (currentRoute == AppRoutes.home) {
      return;
    }

    GoRouter.of(context).go(AppRoutes.home);
  }

  /* Redirige vers la page de profil si l'utilisateur n'est pas déjà sur cette page */
  void _onPressedProfileButton(BuildContext context) {
    final currentRoute = GoRouter.of(context).state.matchedLocation;
    if (currentRoute == AppRoutes.profile) {
      return;
    }

    GoRouter.of(context).push(AppRoutes.profile);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Logo et nom de l'application
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: TextButton.icon(
                    onPressed: () => _onPressedHomeButton(context),
                    icon: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Image.asset(Assets.logo_512, height: 40),
                    ),
                    label: Text(
                      AppConfig.appName,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        fontSize: AppTheme.fontSizes[AppFontSize.xlarge],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Bouton de profil avec le nom de l'utilisateur
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _onPressedProfileButton(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.iconTheme.color ?? Colors.black,
                          width: 2,
                        ),
                      ),
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: Icon(Icons.person_outlined, size: 22),
                      ),
                    ),
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
