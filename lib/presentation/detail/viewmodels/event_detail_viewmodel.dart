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

  EventModel? get event => _event;
  bool get isLoading => _isLoading;
  bool get isParticipating => _isParticipating;
  int get participantCount => _participantCount;
  String? get errorMessage => _errorMessage;

  bool get isFull =>
      _event != null &&
      _event!.maxParticipants != null &&
      _participantCount >= _event!.maxParticipants!;

  Future<void> loadEvent(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _supabase
          .from('events')
          .select()
          .eq('id', id)
          .single();
      _event = EventModel.fromMap(data);

      final countResult = await _supabase
          .from('participants')
          .select('id')
          .eq('event_id', id);
      _participantCount = (countResult as List).length;

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
      debugPrint('Erreur lors du chargement du détail: $e');
      _errorMessage = 'Impossible de charger l\'événement.';
      _event = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> joinEvent() async {
    if (_event == null) return 'Événement introuvable.';
    if (isFull) return 'Le nombre maximum de participants est atteint.';

    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return 'Vous devez être connecté.';

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
    if (_event == null) return 'Événement introuvable.';

    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return 'Vous devez être connecté.';

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
      return 'Erreur lors de la désinscription : $e';
    }
  }
}