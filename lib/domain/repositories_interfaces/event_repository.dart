import '../entities/event_entity.dart';

/// Interface abstraite du repository d'événements.
///
/// Couche Domain - définit le contrat que la couche Data doit implémenter.
/// Cela permet de découpler la logique métier de l'implémentation concrète
/// (Supabase, API REST, cache local, etc.).
abstract class EventRepository {
  /// Récupère la liste de tous les événements.
  Future<List<EventEntity>> getEvents();

  /// Récupère un événement par son identifiant.
  Future<EventEntity?> getEventById(String id);

  /// Crée un nouvel événement et retourne l'entité créée.
  Future<EventEntity> createEvent(EventEntity event);

  /// Met à jour un événement existant.
  Future<void> updateEvent(EventEntity event);

  /// Supprime un événement par son identifiant.
  Future<void> deleteEvent(String id);

  /// Stream temps réel des événements (Supabase Realtime).
  Stream<List<EventEntity>> watchEvents();

  /// Récupère les événements auxquels un utilisateur participe.
  Future<List<EventEntity>> getEventsByUser(String userId);
}
