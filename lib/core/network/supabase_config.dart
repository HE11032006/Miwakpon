import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  static String get _supabaseUrl => dotenv.env['SUPABASE_URL'] ?? 'https://yewbjnprdiilkywxjuff.supabase.co';
  static String get _supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? 'sb_publishable_k-3mWVaN9LkGUC5R6Z1FAQ_YICWz0Oq';

  /// Client Supabase accessible globalement après initialisation.
  static SupabaseClient get client => Supabase.instance.client;

  /// Initialise le client Supabase.
  /// Doit être appelé dans main() avant runApp().
  /// Tente de charger les variables d'environnement depuis .env si présent.
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // Le fichier .env est optionnel, on continue avec les valeurs par défaut
    }
    
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
