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

  /// Les 3 derniers événements postés par l'utilisateur actuel
  List<EventModel> get userEvents {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    final userSpecific = _events.where((e) => e.organizerId == userId).toList();
    
    userSpecific.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (userSpecific.isEmpty && _events.isEmpty) {
      return _mockEvents.where((e) => e.organizerId == 'mock-user').take(3).toList();
    }
    return userSpecific.take(3).toList();
  }

  /// Le Top 3 des événements globaux pour le Feed
  List<EventModel> get featuredEvents {
    final allEvents = _events.isEmpty ? _mockEvents : _events;
    final sorted = List<EventModel>.from(allEvents);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(3).toList();
  }

  /// Alias pour la compatibilité avec la vue actuelle (pour l'instant)
  List<EventModel> get latestEvents => userEvents;

  HomeViewModel() {
    _initRealtimeStream();
  }

  static final List<EventModel> _mockEvents = [
    EventModel(
      id: 'mock-1',
      title: 'Atelier Peinture Impressionniste',
      description: 'Un atelier pour apprendre les techniques de Monet au cœur de Cotonou.',
      dateTime: DateTime.now().add(const Duration(days: 2)),
      location: 'Galerie d\'Art, Cotonou',
      imageUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5',
      organizerId: 'mock-user',
      createdAt: DateTime.now(),
    ),
    EventModel(
      id: 'mock-2',
      title: 'Exposition Couleurs du Bénin',
      description: 'Une immersion dans les chefs-d\'œuvre contemporains béninois.',
      dateTime: DateTime.now().add(const Duration(days: 5)),
      location: 'Palais des Congrès, Cotonou',
      imageUrl: 'https://images.unsplash.com/photo-1513364776144-60967b0f800f',
      organizerId: 'other-user',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    EventModel(
      id: 'mock-3',
      title: 'Festival de Sculpture Vive',
      description: 'Rencontrez les artisans locaux et apprenez la taille sur bois.',
      dateTime: DateTime.now().add(const Duration(days: 10)),
      location: 'Porto-Novo',
      imageUrl: 'https://images.unsplash.com/photo-1582555172866-f73bb12a2ab3',
      organizerId: 'mock-user',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<void> _initRealtimeStream() async {
    try {
      // On commence par écouter le flux AVANT de souscrire pour ne rien rater
      _subscription = _eventService.stream.listen(
        (events) {
          // Si on reçoit des données réelles, on les utilise. 
          // Sinon on garde les mock events pour le rendu visuel.
          _events = events.isEmpty ? _mockEvents : events;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = error.toString();
          _isLoading = false;
          // En cas d'erreur, on affiche quand même les mock pour le design
          _events = _mockEvents;
          notifyListeners();
        },
      );

      // Maintenant on lance la récupération initiale et l'abonnement Realtime
      await _eventService.subscribe();
      
      // Sécurité : si après 2 secondes on est toujours en loading (pas de réponse DB),
      // on affiche les mock data pour ne pas bloquer l'utilisateur.
      Future.delayed(const Duration(seconds: 2), () {
        if (_isLoading) {
          _events = _mockEvents;
          _isLoading = false;
          notifyListeners();
        }
      });
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _events = _mockEvents;
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
