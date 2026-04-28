/// Constantes globales de l'application Miwakpon.
///
/// Ce fichier centralise toutes les constantes utilisées à travers l'app
/// pour éviter les valeurs "magiques" dispersées dans le code.
class AppConstants {
  AppConstants._();

  // --------------------------- App Info ---------------------------
  static const String appName = 'Miwakpon';
  static const String appVersion = '1.0.0';

  // --------------------------- Supabase Tables ---------------------------
  static const String eventsTable = 'events';
  static const String usersTable = 'users';
  static const String participantsTable = 'participants';

  // --------------------------- Routes ---------------------------
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
 static const String createEventRoute = '/events';
  static const String eventDetailRoute = '/detail';
  static const String profileRoute = '/profile';

  // --------------------------- Supabase Realtime Channels ---------------------------
  static const String eventsChannel = 'public:events';

  // --------------------------- Durées & Animations ---------------------------
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationDuration = Duration(milliseconds: 400);
  static const Duration snackBarDuration = Duration(seconds: 3);
}
