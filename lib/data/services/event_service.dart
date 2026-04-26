import '../../core/network/base_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/event_model.dart';

/// Service de données pour les événements avec Supabase Realtime.
///
/// Hérite de BaseRealtimeService pour bénéficier automatiquement
/// du Stream temps réel. Les ViewModels s'abonnent au stream
/// pour recevoir les mises à jour sans bouton refresh.
///
/// Usage dans un ViewModel :
/// ```dart
/// final eventService = EventService();
/// await eventService.subscribe();
/// eventService.stream.listen((events) {
///   // Mise à jour automatique de la UI
/// });
/// ```
class EventService extends BaseRealtimeService<EventModel> {
  EventService() : super(tableName: AppConstants.eventsTable);

  @override
  EventModel fromMap(Map<String, dynamic> map) => EventModel.fromMap(map);
}
