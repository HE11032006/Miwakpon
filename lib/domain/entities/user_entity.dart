/// Entité métier représentant un utilisateur.
///
/// Cette classe appartient à la couche Domain (Clean Architecture).
/// Elle ne dépend d'aucun framework ou package externe.
class UserEntity {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserEntity(id: $id, email: $email)';
}
