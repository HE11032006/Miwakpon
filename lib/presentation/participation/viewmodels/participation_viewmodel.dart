import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/supabase_config.dart';

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
      // Recuperer les participants avec leurs infos utilisateur (username, avatar_url)
      final response = await _supabase
          .from('participants')
          .select('*, users(username, avatar_url, display_name)')
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
    if (_channel != null) return; // Deja souscrit
    
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
    if (userId == null) return 'Vous devez etre connecte.';

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
    if (userId == null) return 'Vous devez etre connecte.';

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
      return 'Erreur lors de la desinscription : $e';
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}