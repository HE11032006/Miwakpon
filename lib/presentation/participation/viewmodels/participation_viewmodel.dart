import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_config.dart';

// TODO: Implémentation par Membre 5
// ViewModel pour la gestion des participants.
//
// Responsabilités :
// - Récupérer la liste des participants d'un événement
// - Gérer l'ajout/suppression de participants
// - Temps réel via Supabase Realtime (table 'participants')

class ParticipationViewModel extends ChangeNotifier {
    final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _participants = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isParticipating = false;
  RealtimeChannel? _channel;

  List<Map<String, dynamic>> get participants => _participants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isParticipating => _isParticipating;
  int get count => _participants.length;

  Future<void> loadParticipants(String eventId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
    .from('participants')
    .select('*')
    .eq('event_id', eventId)
    .order('joined_at', ascending: true);

      _participants = List<Map<String, dynamic>>.from(response);

      final currentUserId = SupabaseConfig.currentUser?.id;
      if (currentUserId != null) {
        _isParticipating = _participants.any(
          (p) => p['user_id'] == currentUserId,
        );
      }

      _subscribeToRealtime(eventId);
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des participants : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToRealtime(String eventId) {
    _channel?.unsubscribe();
    _channel = _supabase
        .channel('participants:$eventId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'participants',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'event_id',
            value: eventId,
          ),
          callback: (_) => loadParticipants(eventId),
        )
        .subscribe();
  }

  Future<String?> joinEvent(String eventId) async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return 'Vous devez être connecté.';

    try {
      await _supabase.from('participants').insert({
        'event_id': eventId,
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
      });
      _isParticipating = true;
      notifyListeners();
      return null;
    } catch (e) {
      return 'Erreur lors de l\'inscription : $e';
    }
  }

  Future<String?> leaveEvent(String eventId) async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return 'Vous devez être connecté.';

    try {
      await _supabase
          .from('participants')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', userId);
      _isParticipating = false;
      notifyListeners();
      return null;
    } catch (e) {
      return 'Erreur lors de la désinscription : $e';
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}