/// Entité métier représentant un événement.
///
/// Cette classe appartient à la couche Domain (Clean Architecture).
/// Elle ne dépend d'aucun framework ou package externe.
/// Les modèles de la couche Data (EventModel) étendent cette entité.
class EventEntity {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final String organizerId;
  final String? organizerName;
  final String? organizerAvatarUrl;
  final String? imageUrl;
  final int maxParticipants;
  final DateTime createdAt;

  const EventEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.organizerId,
    this.organizerName,
    this.organizerAvatarUrl,
    this.imageUrl,
    this.maxParticipants = 50,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'EventEntity(id: $id, title: $title)';
}
