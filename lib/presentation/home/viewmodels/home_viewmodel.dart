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
  bool _isOffline = false;
  String? _errorMessage;
  List<EventModel> _allEvents = [];
  List<EventModel> _filteredEvents = [];
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;

  List<EventModel> get events => _events;

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
          // Detection si c'est une erreur de connexion
          if (error.toString().toLowerCase().contains('socketexception') || 
              error.toString().toLowerCase().contains('connection')) {
            _isOffline = true;
          }
          _errorMessage = 'Impossible de charger les evenements.';
          _isLoading = false;
          notifyListeners();
        },
      );

      await _eventService.subscribe();
      _isOffline = false; // Si l'abonnement reussit, on n'est plus offline
      
      // Securite : si apres 5 secondes on est toujours en loading
      Future.delayed(const Duration(seconds: 5), () {
        if (_isLoading) {
          _isLoading = false;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Exception HomeViewModel: $e');
      if (e.toString().toLowerCase().contains('socketexception') || 
          e.toString().toLowerCase().contains('connection')) {
        _isOffline = true;
      }
      _errorMessage = 'Une erreur est survenue lors de la connexion.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rafraichissement manuel
  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    _isOffline = false; // On retente
    notifyListeners();
    
    try {
      await _eventService.fetchAll();
      _isOffline = false;
    } catch (e) {
      if (e.toString().toLowerCase().contains('socketexception') || 
          e.toString().toLowerCase().contains('connection')) {
        _isOffline = true;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  void dispose() {
    _subscription?.cancel();
    _eventService.dispose();
    super.dispose();
  }
}
