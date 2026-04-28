import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/event_model.dart';
import '../../../data/services/event_service.dart';

class EventListViewModel extends ChangeNotifier {
  final EventService _eventService;
  StreamSubscription<List<EventModel>>? _eventsSubscription;
  
  List<EventModel> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  EventListViewModel(this._eventService) {
    _subscribeToEvents();
  }

  void _subscribeToEvents() {
    _isLoading = true;
    notifyListeners();

    _eventsSubscription = _eventService.stream.listen(
      (eventList) {
        _events = eventList;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = "Erreur temps réel : $error";
        notifyListeners();
      },
    );

    Future.delayed(const Duration(seconds: 5), () {
      if (_isLoading && _events.isEmpty) {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }
}