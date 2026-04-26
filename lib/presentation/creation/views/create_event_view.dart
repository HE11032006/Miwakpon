import 'package:flutter/material.dart';

// TODO: Implémentation par Membre 3
// Écran Figma correspondant : "Conceive an Event"
//
// Ce fichier doit contenir le formulaire de création d'événement.
//
// Champs attendus : titre, description, date/heure, lieu, image, max participants.
// Le design doit suivre les maquettes Figma "Atelier Benin" :
// - Input fields minimalistes avec border-bottom charcoal
// - Focus state en Ocre vibrant
// - Bouton de validation avec ombre dorée (AppColors.shadowGolden)

class CreateEventView extends StatelessWidget {
  const CreateEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un événement'),
      ),
      body: Center(
        child: Text(
          'Create Event View\n// TODO: Implémentation par Membre 3',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
