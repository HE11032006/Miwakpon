import 'package:flutter/material.dart';

// Écran Figma correspondant : "Profile & Settings"
//
// Ce fichier affiche le profil utilisateur et les paramètres.
//
// Design Figma "Atelier Benin" :
// - Avatar circulaire avec ombre impressionniste
// - Sections organisées en cards avec texture différente
// - Bouton déconnexion en bas
// - Informations utilisateur depuis Supabase Auth

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Paramètres'),
      ),
      body: Center(
        child: Text(
          'Profile View\n// TODO: Implémentation par Membre 1',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
