import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuration Singleton pour le client Supabase.
///
/// Initialise la connexion Supabase une seule fois au démarrage
/// de l'application dans main.dart.
///
/// Usage :
/// ```dart
/// await SupabaseConfig.initialize();
/// final client = SupabaseConfig.client;
/// ```
class SupabaseConfig {
  SupabaseConfig._();

  // --------------------------- IMPORTANT ---------------------------
  // Remplacez ces valeurs par vos propres clés Supabase.
  // Idéalement, utilisez un fichier .env non commité.
  // -----------------------------------------------------------
  static const String _supabaseUrl = 'VOTRE_SUPABASE_URL';
  static const String _supabaseAnonKey = 'VOTRE_SUPABASE_ANON_KEY';

  /// Client Supabase accessible globalement après initialisation.
  static SupabaseClient get client => Supabase.instance.client;

  /// Initialise le client Supabase.
  /// Doit être appelé dans main() avant runApp().
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  /// Accès rapide à l'instance d'authentification.
  static GoTrueClient get auth => client.auth;

  /// Accès rapide au canal Realtime.
  static RealtimeChannel channel(String name) {
    return client.channel(name);
  }

  /// Vérifie si un utilisateur est actuellement connecté.
  static bool get isAuthenticated => client.auth.currentUser != null;

  /// Récupère l'utilisateur actuellement connecté, ou null.
  static User? get currentUser => client.auth.currentUser;
}
