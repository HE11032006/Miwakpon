import 'package:flutter/material.dart';

// TODO: Implémentation par Membre 5
// ViewModel pour la gestion des participants.
//
// Responsabilités :
// - Récupérer la liste des participants d'un événement
// - Gérer l'ajout/suppression de participants
// - Temps réel via Supabase Realtime (table 'participants')

class ParticipationViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _participants = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> get participants => _participants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Charge les participants d'un événement.
  Future<void> loadParticipants(String eventId) async {
    // TODO: Implémentation par Membre 5
    _isLoading = true;
    notifyListeners();

    try {
      // final response = await SupabaseConfig.client
      //     .from('participants')
      //     .select('*, users(*)')
      //     .eq('event_id', eventId);
      // _participants = response;
      _participants = [];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
