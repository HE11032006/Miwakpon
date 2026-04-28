import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/router.dart';
import 'core/constants/app_constants.dart';
import 'presentation/auth/viewmodels/auth_viewmodel.dart';
import 'presentation/home/viewmodels/home_viewmodel.dart';
import 'presentation/creation/viewmodels/create_event_viewmodel.dart';
import 'presentation/detail/viewmodels/event_detail_viewmodel.dart';
import 'presentation/participation/viewmodels/participation_viewmodel.dart';
import 'presentation/profile/viewmodels/profile_viewmodel.dart';
import 'presentation/event_list/viewmodels/event_list_viewmodel.dart';
import 'data/services/event_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Supabase
  await SupabaseConfig.initialize();

  runApp(const Miwakpon());
}

/// Application principale - Miwakpon.
///
/// Injecte tous les Providers globaux et configure le thème
/// et le routeur GoRouter.
class Miwakpon extends StatelessWidget {
  const Miwakpon({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --------------------------- Auth (Membre 2) ---------------------------
        ChangeNotifierProvider(create: (_) => AuthViewModel()),

        // --------------------------- Home / Events Feed (Membre 4) ---------------------------
        ChangeNotifierProvider(create: (_) => HomeViewModel()),

        // --------------------------- Création d'événement (Membre 3) ---------------------------
        ChangeNotifierProvider(create: (_) => CreateEventViewModel()),

        // --------------------------- Détails d'événement (Membre 4/5) ---------------------------
        ChangeNotifierProvider(create: (_) => EventDetailViewModel()),

        // --------------------------- Participation (Membre 5) ---------------------------
        ChangeNotifierProvider(create: (_) => ParticipationViewModel()),

        // --------------------------- Profil (Membre 1) ---------------------------
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),

        // --------------------------- Liste des événements (Membre 4) ---------------------------
      ChangeNotifierProvider(create: (_) => EventListViewModel(EventService())),
      ],
      child: Consumer<ProfileViewModel>(
        builder: (context, profileVM, _) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,

            // Thème dynamique basé sur le choix de l'utilisateur
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: profileVM.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            // Navigation GoRouter
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
