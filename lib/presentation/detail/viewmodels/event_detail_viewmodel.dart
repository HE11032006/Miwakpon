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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _supabase
          .from('events')
          .select('*, organizer:organizer_id(*)')
          .eq('id', id)
          .single();
      _event = EventModel.fromMap(data);

      // Recuperer les participants avec leurs infos utilisateur
      final participantsData = await _supabase
          .from('participants')
          .select('id, user_id, users(avatar_url)')
          .eq('event_id', id);
      
      final participants = participantsData as List;
      _participantCount = participants.length;

      // Extraire les avatars des participants
      _participantAvatars = participants.map<String?>((p) {
        final userData = p['users'] as Map<String, dynamic>?;
        return userData?['avatar_url'] as String?;
      }).toList();

      // Verifier si l'utilisateur actuel participe
      final userId = SupabaseConfig.currentUser?.id;
      if (userId != null) {
        final participation = await _supabase
            .from('participants')
            .select('id')
            .eq('event_id', id)
            .eq('user_id', userId)
            .maybeSingle();
        _isParticipating = participation != null;
      }
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
      return 'Erreur lors de l\'inscription : $e';
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
      _participantCount = (_participantCount - 1).clamp(0, 999);
      notifyListeners();
      return null;
    } catch (e) {
      return 'Erreur lors de la desinscription : $e';
    }
  }
}