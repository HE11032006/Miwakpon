import 'package:flutter/material.dart';

// TODO: Implémentation par Membre 4/5
// Écran Figma correspondant : "Event Details"
//
// Ce fichier affiche les détails complets d'un événement.
// Il reçoit l'eventId via GoRouter (paramètre de route).
//
// Design Figma "Atelier Benin" :
// - Image en haut avec overlay gradient
// - Informations dans des cards avec ombre impressionniste
// - Bouton "Participer" en bas avec ombre dorée
// - Liste des participants (Membre 5)

class EventDetailView extends StatelessWidget {
  final String eventId;

  const EventDetailView({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails'),
      ),
      body: Center(
        child: Text(
          'Event Detail View\nID: $eventId\n// TODO: Implémentation par Membre 4/5',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
