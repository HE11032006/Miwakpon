import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  /// 3 evenements recents ou en cours (de tout le monde)
  List<EventModel> get featuredEvents {
    final now = DateTime.now();
    // On prend les evenements qui ne sont pas termines depuis plus de 24h
    final today = DateTime(now.year, now.month, now.day);
    final activeEvents = _events.where((e) => e.dateTime.isAfter(today.subtract(const Duration(days: 1)))).toList();
    
    if (activeEvents.isEmpty) {
      final all = List<EventModel>.from(_events);
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return all.take(3).toList();
    }
    
    // Trier par date de creation pour voir les nouveaux, puis melanger un peu
    activeEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return activeEvents.take(3).toList();
  }

  /// Alias pour la vue
  List<EventModel> get latestEvents => userEvents;

  HomeViewModel() {
    _initRealtimeStream();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) {
        refresh(); // Recharge les evenements pour le nouvel utilisateur
      }
    });
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
          debugPrint('Erreur technique HomeViewModel: $error');
          _errorMessage = 'Impossible de charger les evenements. Veuillez reessayer.';
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
      debugPrint('Exception HomeViewModel: $e');
      _errorMessage = 'Une erreur est survenue lors de la connexion.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rafraichissement manuel
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await _eventService.fetchAll();
    _isLoading = false;
    notifyListeners();
  }
  void dispose() {
    _subscription?.cancel();
    _eventService.dispose();
    super.dispose();
  }
}
