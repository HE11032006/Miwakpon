import '../../domain/entities/event_entity.dart';

/// Modèle de données pour un événement.
///
/// Étend l'entité du domaine et ajoute les méthodes de sérialisation
/// pour communiquer avec Supabase (fromMap / toMap).
class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.dateTime,
    required super.location,
    required super.organizerId,
    super.imageUrl,
    super.maxParticipants,
    required super.createdAt,
  });

  /// Crée un EventModel depuis un Map (réponse Supabase).
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      dateTime: DateTime.parse(map['date_time'] as String),
      location: map['location'] as String? ?? '',
      organizerId: map['organizer_id'] as String,
      imageUrl: map['image_url'] as String?,
      maxParticipants: map['max_participants'] as int? ?? 50,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convertit le modèle en Map pour envoi à Supabase.
  Map<String, dynamic> toMap() {
    final map = {
      'title': title,
      'description': description,
      'date_time': dateTime.toIso8601String(),
      'location': location,
      'organizer_id': organizerId,
      'image_url': imageUrl,
      'max_participants': maxParticipants,
      'created_at': createdAt.toIso8601String(),
    };
    
    // N'inclure l'ID que s'il n'est pas vide (pour les mises à jour)
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    
    return map;
  }

  /// Crée une copie avec certains champs modifiés.
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    String? organizerId,
    String? imageUrl,
    int? maxParticipants,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      organizerId: organizerId ?? this.organizerId,
      imageUrl: imageUrl ?? this.imageUrl,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
