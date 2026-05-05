import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/network/supabase_config.dart';
import '../../../data/models/event_model.dart';
import '../../../data/services/event_service.dart';

class HomeViewModel extends ChangeNotifier {
  final EventService _eventService = EventService();
  StreamSubscription<List<EventModel>>? _subscription;

  List<EventModel> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Les 2 derniers evenements postes par l'utilisateur actuel
  List<EventModel> get userEvents {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    if (userId == null) return [];
    
    final userSpecific = _events.where((e) => e.organizerId == userId).toList();
    userSpecific.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return userSpecific.take(2).toList();
  }

  /// Tous les evenements de l'utilisateur (pour l'historique)
  List<EventModel> get allUserEvents {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    if (userId == null) return [];
    
    final userSpecific = _events.where((e) => e.organizerId == userId).toList();
    userSpecific.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return userSpecific;
  }

  /// 3 evenements aleatoires/melanges en cours (de tout le monde)
  List<EventModel> get featuredEvents {
    final now = DateTime.now();
    // Filtrer les evenements en cours (date future)
    final activeEvents = _events.where((e) => e.dateTime.isAfter(now)).toList();
    
    if (activeEvents.isEmpty) {
      // Fallback sur tous les events si aucun n'est en cours
      final all = List<EventModel>.from(_events);
      all.shuffle(Random());
      return all.take(3).toList();
    }
    
    // Melanger et prendre 3
    activeEvents.shuffle(Random());
    return activeEvents.take(3).toList();
  }

  /// Alias pour la vue
  List<EventModel> get latestEvents => userEvents;

  HomeViewModel() {
    _initRealtimeStream();
  }

  Future<void> _initRealtimeStream() async {
    try {
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

      await _eventService.subscribe();
      
      // Securite : si apres 3 secondes on est toujours en loading
      Future.delayed(const Duration(seconds: 3), () {
        if (_isLoading) {
          _isLoading = false;
          notifyListeners();
        }
      });
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
