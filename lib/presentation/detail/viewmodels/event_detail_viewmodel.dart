import 'package:flutter/material.dart';

import '../../../data/models/event_model.dart';
import '../../../core/network/supabase_config.dart';

// TODO: Implémentation par Membre 4/5
// ViewModel pour les détails d'un événement.
//
// Responsabilités :
// - Charger les détails d'un événement par ID
// - Gérer la participation (rejoindre / quitter)
// - Afficher la liste des participants
//
// Note : Utilisez EventService pour le temps réel quand vous implémentez.
// import '../../../data/services/event_service.dart';

class EventDetailViewModel extends ChangeNotifier {

  EventModel? _event;
  bool _isLoading = true;
  String? _errorMessage;

  EventModel? get event => _event;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Charge les détails d'un événement.
  Future<void> loadEvent(String eventId) async {
    // TODO: Implémentation par Membre 4/5
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseConfig.client
          .from('events')
          .select()
          .eq('id', eventId)
          .single();

      _event = EventModel.fromMap(response);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rejoint un événement.
  Future<void> joinEvent(String eventId) async {
    // TODO: Implémentation par Membre 5
  }

  /// Quitte un événement.
  Future<void> leaveEvent(String eventId) async {
    // TODO: Implémentation par Membre 5
  }
}
