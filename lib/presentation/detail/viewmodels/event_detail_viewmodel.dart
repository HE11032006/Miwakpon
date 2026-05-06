import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/event_model.dart';
import '../../../core/network/supabase_config.dart';

class EventDetailViewModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  EventModel? _event;
  bool _isLoading = false;
  bool _isParticipating = false;
  int _participantCount = 0;
  String? _errorMessage;
  List<String?> _participantAvatars = [];
  RealtimeChannel? _participantsChannel;

  EventModel? get event => _event;
  bool get isLoading => _isLoading;
  bool get isParticipating => _isParticipating;
  int get participantCount => _participantCount;
  String? get errorMessage => _errorMessage;
  List<String?> get participantAvatars => _participantAvatars;

  bool get isFull =>
      _event != null &&
      _participantCount >= _event!.maxParticipants;

  Future<void> loadEvent(String id) async {
    // Vider l'ancien evenement pour eviter de voir ses infos sur le nouveau
    _event = null;
    _participantCount = 0;
    _participantAvatars = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _supabase
          .from('events')
          .select('*, organizer:organizer_id(*)')
          .eq('id', id)
          .single();
      _participantCount = await _fetchParticipantCount(id);
      _participantAvatars = await _fetchParticipantAvatars(id);
      _event = EventModel.fromMap(data);

      _isParticipating = await _checkIfParticipating(id);

      // S'abonner aux changements de participants en temps reel
      _subscribeToParticipants(id);
    } catch (e) {
      debugPrint('Erreur lors du chargement du detail: $e');
      _errorMessage = 'Impossible de charger l\'evenement.';
      _event = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> joinEvent() async {
    if (_event == null) return 'Evenement introuvable.';
    if (isFull) return 'Le nombre maximum de participants est atteint.';

    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return 'Vous devez etre connecte.';

    try {
      await _supabase.from('participants').insert({
        'event_id': _event!.id,
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
      });
      _isParticipating = true;
      _participantCount++;
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('ERREUR TECHNIQUE JOIN: $e');
      return 'Impossible de rejoindre l\'evenement pour le moment.';
    }
  }

  Future<String?> deleteEvent() async {
    if (_event == null) return 'Evenement introuvable.';

    try {
      await _supabase.from('events').delete().eq('id', _event!.id);
      return null;
    } catch (e) {
      debugPrint('ERREUR DELETE EVENT: $e');
      _errorMessage = 'Impossible de supprimer l\'evenement.';
      notifyListeners();
      return 'Impossible de supprimer l\'evenement.';
    }
  }

  Future<String?> leaveEvent() async {
    if (_event == null) return 'Evenement introuvable.';

    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return 'Vous devez etre connecte.';

    try {
      await _supabase
          .from('participants')
          .delete()
          .eq('event_id', _event!.id)
          .eq('user_id', userId);
      _isParticipating = false;
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('ERREUR LEAVE EVENT: $e');
      return 'Impossible de quitter l\'evenement.';
    }
  }

  Future<int> _fetchParticipantCount(String eventId) async {
    final response = await _supabase
        .from('participants')
        .select('id')
        .eq('event_id', eventId);
    return (response as List).length;
  }

  Future<List<String?>> _fetchParticipantAvatars(String eventId) async {
    final response = await _supabase
        .from('participants')
        .select('users(avatar_url)')
        .eq('event_id', eventId)
        .limit(5); // On n'en affiche que quelques-uns dans la bulle
    
    final list = response as List;
    return list.map<String?>((p) {
      final userData = p['users'] as Map<String, dynamic>?;
      return userData?['avatar_url'] as String?;
    }).toList();
  }

  Future<bool> _checkIfParticipating(String eventId) async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return false;
    
    final response = await _supabase
        .from('participants')
        .select('id')
        .eq('event_id', eventId)
        .eq('user_id', userId)
        .maybeSingle();
    return response != null;
  }

  void _subscribeToParticipants(String eventId) {
    _participantsChannel?.unsubscribe();
    
    _participantsChannel = _supabase
        .channel('public:participants:$eventId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'participants',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'event_id',
            value: eventId,
          ),
          callback: (payload) async {
            debugPrint('Changement detecte sur les participants ! Actualisation...');
            _participantCount = await _fetchParticipantCount(eventId);
            _participantAvatars = await _fetchParticipantAvatars(eventId);
            
            // Verifier aussi si l'utilisateur actuel participe toujours
            final currentUserId = SupabaseConfig.currentUser?.id;
            if (currentUserId != null) {
              final participationResponse = await _supabase
                  .from('participants')
                  .select()
                  .eq('event_id', eventId)
                  .eq('user_id', currentUserId)
                  .maybeSingle();
              _isParticipating = participationResponse != null;
            }
            
            notifyListeners();
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _participantsChannel?.unsubscribe();
    super.dispose();
  }
}