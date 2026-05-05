import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../network/supabase_config.dart';

import '../../presentation/splash/views/splash_view.dart';
import '../../presentation/auth/views/login_view.dart';
import '../../presentation/home/views/home_view.dart';
import '../../presentation/creation/views/create_event_view.dart';
import '../../presentation/detail/views/event_detail_view.dart';
import '../../presentation/profile/views/profile_view.dart';
import '../../presentation/widgets/main_layout.dart';
import '../constants/app_constants.dart';
import '../../presentation/event_list/views/event_list_view.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.splashRoute,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      // Splash Screen
      GoRoute(
        path: AppConstants.splashRoute,
        name: 'splash',
        builder: (context, state) => const SplashView(),
      ),

      // Authentification
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        builder: (context, state) => const LoginView(),
      ),

      // Route de création (Global)
      GoRoute(
        path: '/create',
        name: 'create_event',
        builder: (context, state) => const CreateEventView(),
      ),

      // Shell Route (Main Layout)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          // Branche 0 : Tableau de Bord
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppConstants.homeRoute,
                name: 'home',
                builder: (context, state) => const HomeView(),
                routes: [
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

          // Branche 1 : Liste des événements (Version de l'ami)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/events',
                name: 'events_list',
                builder: (context, state) => const EventListView(),
                routes: [
                  GoRoute(
                    path: 'detail/:id',
                    name: 'events_detail',
                    builder: (context, state) {
                      final eventId = state.pathParameters['id']!;
                      return EventDetailView(eventId: eventId);
                    },
                  ),
                ],
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

    redirect: (context, state) {
      final isAuthenticated = SupabaseConfig.isAuthenticated;
      final isLoginRoute = state.matchedLocation == AppConstants.loginRoute;
      final isSplashRoute = state.matchedLocation == AppConstants.splashRoute;

      if (!isAuthenticated && !isLoginRoute && !isSplashRoute) {
        return AppConstants.loginRoute;
      }

      if (isAuthenticated && (isLoginRoute || isSplashRoute)) {
        return AppConstants.homeRoute;
      }

      return null;
    },

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
