import 'dart:async';
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

  /// Événements postés par l'utilisateur actuel
  List<EventModel> get userEvents {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    if (userId == null) return [];
    return _events.where((e) => e.organizerId == userId).toList();
  }

  /// Les derniers événements globaux (excluant potentiellement ceux de l'utilisateur si souhaité, 
  /// mais ici on prend les plus récents en général)
  List<EventModel> get latestEvents {
    final sorted = List<EventModel>.from(_events);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  HomeViewModel() {
    _initRealtimeStream();
  }

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
