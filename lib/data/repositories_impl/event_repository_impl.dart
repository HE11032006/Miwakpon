import '../../domain/entities/event_entity.dart';
import '../../domain/repositories_interfaces/event_repository.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

/// Implémentation concrète du repository d'événements.
///
/// Utilise EventService (Supabase Realtime) pour les opérations CRUD
/// et le streaming temps réel. Cette classe fait le pont entre
/// la couche Domain (abstraite) et la couche Data (Supabase).
class EventRepositoryImpl implements EventRepository {
  final EventService _eventService;

  EventRepositoryImpl({EventService? eventService})
      : _eventService = eventService ?? EventService();

  @override
  Future<List<EventEntity>> getEvents() async {
    // TODO: Implémentation - récupérer via Supabase
    // Utiliser _eventService pour le fetch initial
    return [];
  }

  @override
  Future<EventEntity?> getEventById(String id) async {
    // TODO: Implémentation - récupérer un événement par ID
    return null;
  }

  @override
  Future<EventEntity> createEvent(EventEntity event) async {
    // TODO: Implémentation - insérer via _eventService.insert()
    final model = EventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      dateTime: event.dateTime,
      location: event.location,
      organizerId: event.organizerId,
      imageUrl: event.imageUrl,
      maxParticipants: event.maxParticipants,
      createdAt: event.createdAt,
    );
    await _eventService.insert(model.toMap());
    return event;
  }

  @override
  Future<void> updateEvent(EventEntity event) async {
    // TODO: Implémentation - mise à jour via _eventService.update()
    final model = EventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      dateTime: event.dateTime,
      location: event.location,
      organizerId: event.organizerId,
      imageUrl: event.imageUrl,
      maxParticipants: event.maxParticipants,
      createdAt: event.createdAt,
    );
    await _eventService.update(model.id, model.toMap());
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _eventService.delete(id);
  }

  @override
  Stream<List<EventEntity>> watchEvents() {
    // Branchement direct au Stream Supabase Realtime
    return _eventService.stream;
  }

  @override
  Future<List<EventEntity>> getEventsByUser(String userId) async {
    // TODO: Implémentation - filtrer par userId
    return [];
  }

  /// Initialise la souscription au Realtime.
  /// À appeler au démarrage de l'application.
  Future<void> initialize() async {
    await _eventService.subscribe();
  }

  /// Libère les ressources.
  Future<void> dispose() async {
    await _eventService.dispose();
  }
}
