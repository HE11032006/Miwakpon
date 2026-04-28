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
  /// Retourne null si non initialisé.
  static SupabaseClient? get client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      debugPrint('Supabase n\'est pas encore initialisé ou a échoué: $e');
      return null;
    }
  }

  /// Initialise le client Supabase.
  /// Doit être appelé dans main() avant runApp().
  /// Tente de charger les variables d'environnement depuis .env si présent.
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // Le fichier .env est optionnel
    }
    
    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('ERREUR lors de Supabase.initialize: $e');
      // On ne re-throw pas pour éviter de bloquer l'app au démarrage
    }
  }

  /// Accès rapide à l'instance d'authentification.
  static GoTrueClient? get auth => client?.auth;

  /// Accès rapide au canal Realtime.
  static RealtimeChannel? channel(String name) {
    return client?.channel(name);
  }

  /// Vérifie si un utilisateur est actuellement connecté.
  static bool get isAuthenticated => auth?.currentUser != null;

  /// Récupère l'utilisateur actuellement connecté, ou null.
  static User? get currentUser => auth?.currentUser;
}
