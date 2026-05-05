import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

/// Service de base abstrait pour les appels Supabase Realtime.
///
/// Fournit la mécanique de souscription aux changements en temps réel
/// d'une table Supabase. Les services concrets héritent de cette classe
/// et implémentent [fromMap] pour convertir les données.
///
/// Usage (voir EventService pour un exemple concret) :
/// ```dart
/// class EventService extends BaseRealtimeService<EventModel> {
///   EventService() : super(tableName: 'events');
///
///   @override
///   EventModel fromMap(Map<String, dynamic> map) => EventModel.fromMap(map);
/// }
/// ```
abstract class BaseRealtimeService<T> {
  final String tableName;
  final String selectQuery;
  final SupabaseClient _client = SupabaseConfig.client;

  RealtimeChannel? _channel;
  final StreamController<List<T>> _streamController =
      StreamController<List<T>>.broadcast();

  BaseRealtimeService({required this.tableName, this.selectQuery = '*'});

  /// Convertit un Map en objet métier. À implémenter par les sous-classes.
  T fromMap(Map<String, dynamic> map);

  /// Stream des données en temps réel.
  Stream<List<T>> get stream => _streamController.stream;

  /// Récupère toutes les données de la table et écoute les changements.
  Future<void> subscribe() async {
    // Chargement initial
    await fetchAll();

    // Nom de canal unique pour eviter les conflits
    final channelName = 'public:$tableName:${DateTime.now().millisecondsSinceEpoch}';

    // Écoute des changements en temps réel
    _channel = _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: tableName,
          callback: (payload) async {
            // Petit delai pour laisser le temps a Supabase de propager
            await Future.delayed(const Duration(milliseconds: 300));
            fetchAll();
          },
        )
        .subscribe();
  }

  /// Récupère toutes les entrées de la table.
  Future<void> fetchAll() async {
    try {
      final response = await _client.from(tableName).select(selectQuery);
      final List<T> items =
          (response as List).map((e) => fromMap(e as Map<String, dynamic>)).toList();
      _streamController.add(items);
    } catch (e) {
      _streamController.addError(e);
    }
  }

  /// Insère un nouvel élément dans la table.
  Future<void> insert(Map<String, dynamic> data) async {
    await _client.from(tableName).insert(data);
  }

  /// Met à jour un élément existant par son id.
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _client.from(tableName).update(data).eq('id', id);
  }

  /// Supprime un élément par son id.
  Future<void> delete(String id) async {
    await _client.from(tableName).delete().eq('id', id);
  }

  /// Se désabonne du canal Realtime et ferme le stream.
  Future<void> dispose() async {
    await _channel?.unsubscribe();
    await _streamController.close();
  }
}
