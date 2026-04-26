import 'package:flutter/material.dart';

// TODO: Implémentation par Membre 5
// Écran Figma correspondant : "Participants List"
//
// Ce fichier affiche la liste des participants d'un événement.
//
// Design Figma "Atelier Benin" :
// - Liste avec séparateurs "brushstroke"
// - Avatars circulaires avec ombre légère
// - Chips pour le statut (confirmé, en attente)

class ParticipationView extends StatelessWidget {
  const ParticipationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participants'),
      ),
      body: Center(
        child: Text(
          'Participation View\n// TODO: Implémentation par Membre 5',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
