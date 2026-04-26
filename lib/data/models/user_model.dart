import '../../domain/entities/user_entity.dart';

/// Modèle de données pour un utilisateur.
///
/// Étend l'entité du domaine et ajoute les méthodes de sérialisation
/// pour communiquer avec Supabase (fromMap / toMap).
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.avatarUrl,
    required super.createdAt,
  });

  /// Crée un UserModel depuis un Map (réponse Supabase).
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['display_name'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convertit le modèle en Map pour envoi à Supabase.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Crée une copie avec certains champs modifiés.
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
