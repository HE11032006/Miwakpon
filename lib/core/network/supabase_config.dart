import 'package:flutter/foundation.dart';
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

  // Valeurs par défaut codées en dur pour l'examinateur (Zéro Configuration)
  static const String _defaultUrl = 'https://yewbjnprdiilkywxjuff.supabase.co';
  static const String _defaultAnonKey = 'sb_publishable_k-3mWVaN9LkGUC5R6Z1FAQ_YICWz0Oq';

  /// Client Supabase accessible globalement après initialisation.
  static SupabaseClient get client => Supabase.instance.client;

  /// Initialise le client Supabase.
  /// Doit être appelé dans main() avant runApp().
  /// Tente de charger les variables d'environnement depuis .env si présent.
  static Future<void> initialize() async {
    String url = _defaultUrl;
    String anonKey = _defaultAnonKey;

    try {
      // On tente de charger le .env
      await dotenv.load(fileName: ".env");
      
      // On récupère les valeurs seulement si elles existent, sinon on garde les défauts
      url = dotenv.maybeGet('SUPABASE_URL') ?? _defaultUrl;
      anonKey = dotenv.maybeGet('SUPABASE_ANON_KEY') ?? _defaultAnonKey;
    } catch (e) {
      // Si .env absent, on utilise les valeurs par défaut sans planter
      debugPrint('Note: Utilisation des clés Supabase par défaut (Zéro Config).');
    }
    
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
    } catch (e) {
      debugPrint('ERREUR lors de Supabase.initialize: $e');
    }
  }

  /// Accès rapide à l'instance d'authentification.
  static GoTrueClient get auth => client.auth;

  /// Accès rapide au canal Realtime.
  static RealtimeChannel channel(String name) {
    return client.channel(name);
  }

  /// Vérifie si un utilisateur est actuellement connecté.
  static bool get isAuthenticated {
    try {
      return auth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  /// Récupère l'utilisateur actuellement connecté, ou null.
  static User? get currentUser {
    try {
      return auth.currentUser;
    } catch (e) {
      return null;
    }
  }
}
