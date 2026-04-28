import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/event_model.dart';
import '../../../data/services/event_service.dart';

class EventListViewModel extends ChangeNotifier {
  final EventService _eventService = EventService();
  StreamSubscription<List<EventModel>>? _subscription;

  List<EventModel> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  EventListViewModel() {
    _loadMockData(); // On utilise les mocks pour le nouveau design
  }

  Future<void> _loadMockData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _events = [
      EventModel(
        id: '1',
        title: 'Agogohoun in Ouidah',
        description: 'Une célébration rythmée au cœur du fort historique.',
        location: 'Historic Fort Precinct',
        dateTime: DateTime(2026, 10, 14),
        organizerId: 'admin',
        createdAt: DateTime.now(),
      ),
      EventModel(
        id: '2',
        title: 'Gelede Mask Exhibition',
        description: 'Découvrez la richesse culturelle des masques Gelede.',
        location: 'Porto-Novo Museum',
        dateTime: DateTime(2026, 11, 2),
        organizerId: 'admin',
        createdAt: DateTime.now(),
      ),
      EventModel(
        id: '3',
        title: 'Zangbeto Night Call',
        description: 'Une cérémonie nocturne traditionnelle mystique.',
        location: 'Abomey Center',
        dateTime: DateTime(2026, 11, 18),
        organizerId: 'admin',
        createdAt: DateTime.now(),
      ),
      EventModel(
        id: '4',
        title: 'Artisan Market Flow',
        description: 'Marché artisanal contemporain.',
        location: 'Cotonou Arts Center',
        dateTime: DateTime(2026, 12, 5),
        organizerId: 'admin',
        createdAt: DateTime.now(),
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  // ignore: unused_element
  Future<void> _initRealtimeStream() async {
    await _subscription?.cancel();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _eventService.subscribe();
      _subscription = _eventService.stream.listen(
        (newList) {
          _events = newList;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        },
        onError: (error) {
          _isLoading = false;
          _errorMessage = "Erreur de flux : ${error.toString()}";
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = "Erreur Supabase : $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadEvents() async {
    await _loadMockData();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}