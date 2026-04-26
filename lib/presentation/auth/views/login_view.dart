import 'package:flutter/material.dart';

// TODO: Implémentation par Membre 2
// Écran Figma correspondant : "Authentication"
//
// Ce fichier doit contenir le formulaire de connexion/inscription
// utilisant Supabase Auth (email + password).
//
// Le design doit suivre les maquettes Figma "Atelier Benin" :
// - Input fields avec border-bottom style charcoal
// - Bouton principal en Ocre avec inner-glow
// - Typographie Newsreader pour le titre, Be Vietnam Pro pour les champs

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Login View\n// TODO: Implémentation par Membre 2',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
