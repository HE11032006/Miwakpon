import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/event_model.dart';

class EventDetailViewModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  EventModel? _event;
  bool _isLoading = false;

  EventModel? get event => _event;
  bool get isLoading => _isLoading;

  Future<void> loadEvent(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('events')
          .select()
          .eq('id', id)
          .single();

      _event = EventModel.fromMap(data);
    } catch (e) {
      debugPrint("Erreur lors du chargement du détail: $e");
      _event = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}