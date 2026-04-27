import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/splash/views/splash_view.dart';
import '../../presentation/auth/views/login_view.dart';
import '../../presentation/home/views/home_view.dart';
import '../../presentation/creation/views/create_event_view.dart';
import '../../presentation/detail/views/event_detail_view.dart';
import '../../presentation/profile/views/profile_view.dart';
import '../../presentation/widgets/main_layout.dart';
import '../constants/app_constants.dart';

/// Configuration du routeur GoRouter.
///
/// Routes configurées :
/// - /         : SplashView
/// - /login    : LoginView          (Membre 2)
/// - /home     : HomeView           (Membre 4)
/// - /create   : CreateEventView    (Membre 3)
/// - /detail/:id : EventDetailView  (Membre 4/5)
/// - /profile  : ProfileView        (Membre 1)
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.profileRoute,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      // --------------------------- Splash Screen ---------------------------
      GoRoute(
        path: AppConstants.splashRoute,
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashView();
        },
      ),

      // --------------------------- Authentification (Membre 2) ---------------------------
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginView();
        },
      ),

      // --------------------------- Shell Route (Main Layout) ---------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          // Branche 0 : Accueil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConstants.homeRoute,
                name: 'home',
                builder: (context, state) => const HomeView(),
                routes: [
                  // Détail de l'événement est un sous-écran de l'accueil
                  GoRoute(
                    path: 'detail/:id',
                    name: 'detail',
                    builder: (context, state) {
                      final eventId = state.pathParameters['id']!;
                      return EventDetailView(eventId: eventId);
                    },
                  ),
                ],
              ),
            ],
          ),
          
          // Branche 1 : Création
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConstants.createEventRoute,
                name: 'create',
                builder: (context, state) => const CreateEventView(),
              ),
            ],
          ),

          // Branche 2 : Profil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConstants.profileRoute,
                name: 'profile',
                builder: (context, state) => const ProfileView(),
              ),
            ],
          ),
        ],
      ),
    ],

    // --------------------------- Redirection (gestion auth) ---------------------------
    // TODO: Ajouter la logique de redirection basée sur l'état
    // d'authentification Supabase une fois le AuthViewModel prêt.

    // --------------------------- Page d'erreur ---------------------------
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page introuvable : ${state.uri}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    ),
  );
}
