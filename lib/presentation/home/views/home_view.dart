import 'package:flutter/material.dart';

// TODO: Implémentation par Membre 4
// Écrans Figma correspondants :
// - "Events Dashboard Updated"
// - "Events Feed"
//
// Ce fichier doit afficher la liste des événements en temps réel.
// Le ViewModel fournit un Stream - PAS BESOIN de bouton refresh.
//
// Design Figma "Atelier Benin" :
// - Cards sans bordures, définies par un changement de texture de fond
// - Ombre ambiante teintée Indigo (AppColors.shadowIndigo)
// - Séparateurs "brushstroke" qui s'amincissent aux extrémités
// - FAB en Ocre pour créer un événement

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Text(
          'Home View - Events Feed\n// TODO: Implémentation par Membre 4',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
