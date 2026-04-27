import 'package:flutter/material.dart';

// Écran Figma correspondant : "Profile & Settings"
//
// Ce fichier affiche le profil utilisateur et les paramètres.
//
// Design Figma "Atelier Benin" :
// - Avatar circulaire avec ombre impressionniste
// - Sections organisées en cards avec texture différente
// - Bouton déconnexion en bas
// - Informations utilisateur depuis Supabase Auth

import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: AppColors.shadowLight,
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  backgroundImage: viewModel.avatarUrl != null
                      ? NetworkImage(viewModel.avatarUrl!)
                      : null,
                  child: viewModel.avatarUrl == null
                      ? const Icon(Icons.person, size: 60, color: AppColors.primary)
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              
              // Titre (Nom)
              Text(
                viewModel.displayName ?? 'Adebayo The Artisan',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Bio
              Text(
                'Crafting digital landscapes inspired by Beninese heritage. Master of the fluid grid.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),

              // Account Details Card
              _sectionCard(
                context,
                icon: Icons.account_circle,
                title: 'Account Details',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow(context, 'Email Address', viewModel.email ?? 'adebayo.artisan@alatinsa.co'),
                    const SizedBox(height: 16),
                    _detailRow(context, 'Phone Number', '+234 800 123 4567'),
                    const SizedBox(height: 16),
                    _detailRow(context, 'Atelier Location', 'Victoria Island, Lagos'),
                  ],
                ),
              ),

              // Alerts Card
              _sectionCard(
                context,
                icon: Icons.notifications_active,
                title: 'Alerts',
                child: const SizedBox.shrink(), // Vide dans la maquette
              ),

              // Atelier Theme Card
              _sectionCard(
                context,
                icon: Icons.palette,
                title: 'Atelier Theme',
                child: Text(
                  'Select the atmospheric light for your workspace.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              // NOTE: Bouton de déconnexion à faire par le Membre 1
            ],
          ),
        );
      },
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.shadowIndigo,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
