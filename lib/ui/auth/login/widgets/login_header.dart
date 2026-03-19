import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    /// Affiche une boîte de dialogue expliquant comment fonctionne la création de compte et l'authentification.
    void showCreateAccountHelper() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Comment fonctionne l\'authentification ?'),
          content: const Text(
            'Il n\'y a aucune différence pour vous entre la connexion et l\'inscription.\n\nEntrez votre adresse e-mail pour vous connecter ou créer un compte.\n\nSi vous avez déjà un compte avec cette adresse e-mail, cela vous permettra de vous connectez et donc de retrouver vos données.\nSi vous n’avez pas de compte, un compte vous sera créé.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
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
          title: const Text('Pourquoi il n\'y a pas de mot de passe ?'),
          content: const Text(
            'Éconoris utilise une méthode d\'authentification sans mot de passe pour simplifier le processus de connexion.\n\nLorsque vous entrez votre adresse e-mail, Éconoris vous envoie un code à usage unique par e-mail que vous devez saisir pour vérifier votre identité.\n\nCette méthode est plus simple et plus sécurisée, car elle élimine les risques associés aux mots de passe faibles, réutilisés, compromis ou oubliés.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
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
          title: const Text('Comment sont sécurisés mes données ?'),
          content: const Text(
            'Éconoris prend la sécurité de vos données très au sérieux. Nous utilisons des protocoles de sécurité avancés pour protéger vos informations personnelles et financières.\n\nAucune données utilisateur est utilisée à quelconque fin commerciale ou publicitaire. Nous ne partageons pas vos données avec des tiers.\n\nNous récoltons et stockons le minimum d\'information personnel que possible.\n\nToutes vos données sont stockées de manière sécurisée sur des serveurs Français qui appartiennent à une société Française également.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
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
