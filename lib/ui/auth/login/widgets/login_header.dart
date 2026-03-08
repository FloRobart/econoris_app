import 'package:econoris_app/config/assets.dart';
import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    /// Affiche une boîte de dialogue expliquant comment fonctionne la création de compte et l'authentification.
    void showCreateAccountHelper() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Comment fonctionne l\'authentification ?'),
          content: Text(
            'Entre ton adresse e-mail pour te connecter ou créer un compte.\n\nSi vous avez déjà un compte avec cette adresse e-mail, cela vous permettra de vous connectez et donc de retrouver vos données.\nSi vous n’avez pas de compte, un compte vous sera créé.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
            ),
          ],
        ),
      );
    }

    /// Affiche une boîte de dialogue expliquant pourquoi il n'y a pas de mot de passe.
    void showPasswordHelper() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Pourquoi il n\'y a pas de mot de passe ?'),
          content: Text(
            'Éconoris utilise une méthode d\'authentification sans mot de passe pour simplifier le processus de connexion.\n\nLorsque vous entrez votre adresse e-mail, Éconoris vous envoie un code à usage unique par e-mail que vous devez saisir pour vérifier votre identité.\n\nCette méthode est plus simple et plus sécurisée, car elle élimine les risques associés aux mots de passe faibles, réutilisés, compromis ou oubliés.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
            ),
          ],
        ),
      );
    }

    /// Affiche une boîte de dialogue expliquant comment les données sont sécurisées.
    void showSecurityHelper() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Comment sont sécurisés mes données ?'),
          content: Text(
            'Éconoris prend la sécurité de vos données très au sérieux. Nous utilisons des protocoles de sécurité avancés pour protéger vos informations personnelles et financières.\n\nAucune données utilisateur est utilisée à quelconque fin commerciale ou publicitaire. Nous ne partageons pas vos données avec des tiers.\n\nNous récoltons et stockons le minimum d\'information personnel que possible.\n\nToutes vos données sont stockées de manière sécurisée sur des serveurs Français qui appartiennent à une société Française également.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
            ),
          ],
        ),
      );
    }

    return Column(
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
          'Bienvenue sur Econoris',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'Connectez-vous pour retrouver vos finances en un coup d’œil. Éconoris vous permets de suivre vos dépenses et gérer votre budget de façon très simple et rapide.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'Econoris est gratuit, sans publicité, et respecte votre vie privée.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Comment créer un compte ?'),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: showCreateAccountHelper,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: Icon(Icons.help_outline, size: 20),
              ),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Pourquoi il n\'y a pas de mot de passe ?'),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: showPasswordHelper,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: Icon(Icons.help_outline, size: 20),
              ),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Comment sont sécurisés mes données ?'),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: showSecurityHelper,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: Icon(Icons.help_outline, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
