import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/models/event_model.dart';
import '../../../data/services/event_service.dart';

// TODO: Implémentation par Membre 4
// ViewModel pour l'affichage des événements en temps réel.
//
// ---------------------------------------------------------------
// MÉCANIQUE DE DONNÉES TEMPS RÉEL (déjà branchée) :
//
// Ce ViewModel s'abonne au Stream<List<EventModel>> de EventService.
// Chaque fois qu'un événement est créé/modifié/supprimé dans Supabase,
// le stream émet automatiquement la nouvelle liste.
//
// La UI (HomeView) doit utiliser Consumer<HomeViewModel> pour
// se reconstruire automatiquement à chaque changement.
//
// - Pas besoin de bouton "refresh" - tout est en temps réel.
// ---------------------------------------------------------------

class HomeViewModel extends ChangeNotifier {
  final EventService _eventService = EventService();
  StreamSubscription<List<EventModel>>? _subscription;

  List<EventModel> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  HomeViewModel() {
    _initRealtimeStream();
  }

  /// Initialise la souscription au stream Supabase Realtime.
  /// Les données arrivent automatiquement - pas de fetch manuel.
  Future<void> _initRealtimeStream() async {
    try {
      await _eventService.subscribe();

      _subscription = _eventService.stream.listen(
        (events) {
          _events = events;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _eventService.dispose();
    super.dispose();
  }
}
