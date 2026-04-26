import 'package:flutter/material.dart';

import '../../../data/models/event_model.dart';
import '../../../data/services/event_service.dart';

// TODO: Implémentation par Membre 3
// ViewModel pour la création d'événements.
//
// Responsabilités :
// - Valider les champs du formulaire
// - Appeler EventService.insert() pour créer l'événement
// - Gérer les états loading/success/error

class CreateEventViewModel extends ChangeNotifier {
  final EventService _eventService = EventService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  /// Crée un nouvel événement.
  Future<void> createEvent({
    required String title,
    required String description,
    required DateTime dateTime,
    required String location,
    required String organizerId,
    String? imageUrl,
    int maxParticipants = 50,
  }) async {
    // TODO: Implémentation par Membre 3
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final event = EventModel(
        id: '', // Supabase génère l'ID
        title: title,
        description: description,
        dateTime: dateTime,
        location: location,
        organizerId: organizerId,
        imageUrl: imageUrl,
        maxParticipants: maxParticipants,
        createdAt: DateTime.now(),
      );

      await _eventService.insert(event.toMap());
      _isSuccess = true;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
