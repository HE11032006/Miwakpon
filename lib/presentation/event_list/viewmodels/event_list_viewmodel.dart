import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/network/supabase_config.dart';
import '../../../data/models/event_model.dart';
import '../../../data/services/event_service.dart';

class EventListViewModel extends ChangeNotifier {
  final EventService _eventService;
  StreamSubscription<List<EventModel>>? _eventsSubscription;
  
  List<EventModel> _allEvents = [];
  List<EventModel> _filteredEvents = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filtres
  String _searchQuery = '';
  String _locationFilter = '';
  DateTime? _dateFilter;
  bool _showOnlyMine = false;

  List<EventModel> get events => _filteredEvents;
  List<EventModel> get allEvents => _allEvents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get locationFilter => _locationFilter;
  DateTime? get dateFilter => _dateFilter;
  bool get showOnlyMine => _showOnlyMine;

  EventListViewModel(this._eventService) {
    _subscribeToEvents();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setLocationFilter(String location) {
    _locationFilter = location;
    _applyFilters();
  }

  void setDateFilter(DateTime? date) {
    _dateFilter = date;
    _applyFilters();
  }

  void toggleShowOnlyMine() {
    _showOnlyMine = !_showOnlyMine;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _locationFilter = '';
    _dateFilter = null;
    _showOnlyMine = false;
    _applyFilters();
  }

  void _applyFilters() {
    List<EventModel> result = List.from(_allEvents);

    // Filtre par nom
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((e) => 
        e.title.toLowerCase().contains(query) ||
        e.description.toLowerCase().contains(query)
      ).toList();
    }

    // Filtre par lieu
    if (_locationFilter.isNotEmpty) {
      final loc = _locationFilter.toLowerCase();
      result = result.where((e) => 
        e.location.toLowerCase().contains(loc)
      ).toList();
    }

    // Filtre par date
    if (_dateFilter != null) {
      result = result.where((e) => 
        e.dateTime.year == _dateFilter!.year &&
        e.dateTime.month == _dateFilter!.month &&
        e.dateTime.day == _dateFilter!.day
      ).toList();
    }

    // Filtre mes evenements uniquement
    if (_showOnlyMine) {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId != null) {
        result = result.where((e) => e.organizerId == userId).toList();
      }
    }

    // Trier par date de creation (plus recent en premier)
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _filteredEvents = result;
    notifyListeners();
  }

  Future<void> _subscribeToEvents() async {
    _isLoading = true;
    notifyListeners();

    _eventsSubscription = _eventService.stream.listen(
      (eventList) {
        _allEvents = eventList;
        _applyFilters();
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Erreur temps reel EventList: $error');
        _isLoading = false;
        _errorMessage = "Impossible de mettre a jour la liste.";
        notifyListeners();
      },
    );

    try {
      await _eventService.subscribe();
    } catch (e) {
      debugPrint('Exception EventList: $e');
      _errorMessage = "Une erreur est survenue lors du chargement.";
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }
}