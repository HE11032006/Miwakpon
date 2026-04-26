import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

/// Écran Splash - Point d'entrée de l'application.
///
/// Affiche le logo et le nom de l'app pendant le chargement initial.
/// Redirige automatiquement vers /login ou /home selon l'état d'auth.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(AppConstants.splashDuration);
    if (mounted) {
      // TODO: Vérifier l'état d'authentification Supabase
      // Si connecté : /home, sinon : /login
      context.go(AppConstants.loginRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder avec ombre impressionniste
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
                boxShadow: AppColors.shadowGolden,
              ),
              child: const Icon(
                Icons.event,
                size: 56,
                color: AppColors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
