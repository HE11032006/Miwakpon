import 'package:flutter/material.dart';

// Écran Figma correspondant : "Profile & Settings"
//
// Ce fichier affiche le profil utilisateur et les paramètres.
//
// Design Figma "Atelier Benin" :
// - Avatar circulaire avec badge d'édition
// - Chips "Maître Artisan" / "Atelier Lagos"
// - Sections en cards : Détails du compte, Alertes, Thème Atelier
// - Bouton Déconnexion en bas
// - Informations utilisateur depuis Supabase Auth

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // ======================== AVATAR ========================
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: AppColors.shadowMedium,
                    ),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      backgroundImage: viewModel.avatarUrl != null
                          ? NetworkImage(viewModel.avatarUrl!)
                          : null,
                      child: viewModel.avatarUrl == null
                          ? const Icon(Icons.person,
                              size: 56, color: AppColors.primary)
                          : null,
                    ),
                  ),
                  // Badge d'édition
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ======================== NOM ========================
              Text(
                viewModel.displayName ?? 'Artisan Béninois',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
              ),
              const SizedBox(height: 8),

              // ======================== BIO ========================
              Text(
                'Création de paysages numériques inspirés du patrimoine béninois. Maître de la grille fluide.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 16),

              // ======================== CHIPS ========================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _chip(context, 'Maître Artisan'),
                  const SizedBox(width: 8),
                  _chip(context, 'Atelier Lagos'),
                ],
              ),
              const SizedBox(height: 32),

              // ======================== DÉTAILS DU COMPTE ========================
              _sectionCard(
                context,
                icon: Icons.account_circle_outlined,
                title: 'Détails du compte',
                child: Column(
                  children: [
                    _detailRow(
                      context,
                      icon: Icons.email_outlined,
                      label: 'Adresse e-mail',
                      value: viewModel.email ?? 'Non renseigné',
                    ),
                    const Divider(height: 24),
                    _editableDetailRow(
                      context,
                      icon: Icons.phone_outlined,
                      label: 'Numéro de téléphone',
                      value: viewModel.phone ?? 'Non renseigné',
                      onSave: (val) => viewModel.updatePhone(val),
                    ),
                    const Divider(height: 24),
                    _editableDetailRow(
                      context,
                      icon: Icons.location_on_outlined,
                      label: 'Localisation de l\'atelier',
                      value: viewModel.location ?? 'Non renseigné',
                      onSave: (val) => viewModel.updateLocation(val),
                    ),
                  ],
                ),
              ),

              // ======================== ALERTES ========================
              _sectionCard(
                context,
                icon: Icons.notifications_active_outlined,
                title: 'Alertes',
                child: Column(
                  children: [
                    _alertRow(
                      context,
                      title: 'Nouvelles commissions',
                      subtitle: 'Notifications push et e-mail',
                      value: viewModel.newCommissions,
                      onChanged: viewModel.toggleNewCommissions,
                    ),
                    const Divider(height: 16),
                    _alertRow(
                      context,
                      title: 'Mises à jour expositions',
                      subtitle: 'Notifications push et e-mail',
                      value: viewModel.exhibitionUpdates,
                      onChanged: viewModel.toggleExhibitionUpdates,
                    ),
                    const Divider(height: 16),
                    _alertRow(
                      context,
                      title: 'Alertes sécurité',
                      subtitle: 'Notifications SMS et e-mail',
                      value: viewModel.securityAlerts,
                      onChanged: viewModel.toggleSecurityAlerts,
                    ),
                  ],
                ),
              ),

              // ======================== THÈME ATELIER ========================
              _sectionCard(
                context,
                icon: Icons.palette_outlined,
                title: 'Thème Atelier',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sélectionnez la lumière atmosphérique de votre espace.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _themeOption(
                            context,
                            index: 0,
                            isSelected: viewModel.selectedTheme == 0,
                            onTap: () => viewModel.setTheme(0),
                            gradientColors: [
                              AppColors.canvasWhite,
                              AppColors.primary.withValues(alpha: 0.15),
                              AppColors.secondary.withValues(alpha: 0.1),
                            ],
                            label: 'Lumière Aube',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _themeOption(
                            context,
                            index: 1,
                            isSelected: viewModel.selectedTheme == 1,
                            onTap: () => viewModel.setTheme(1),
                            gradientColors: [
                              AppColors.inverseSurface,
                              AppColors.secondary.withValues(alpha: 0.8),
                              AppColors.primary.withValues(alpha: 0.4),
                            ],
                            label: 'Ombre Crépuscule',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ======================== DÉCONNEXION ========================
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // TODO: Logique à compléter par le Membre 1
                    await viewModel.signOut();
                    if (context.mounted) {
                      context.go(AppConstants.loginRoute);
                    }
                  },
                  icon: Icon(
                    Icons.logout,
                    color: AppColors.error,
                    size: 20,
                  ),
                  label: Text(
                    'Déconnexion',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.error,
                        ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }

  // ======================== WIDGETS HELPERS ========================

  Widget _chip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
      ),
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
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.shadowIndigo,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 26),
              const SizedBox(width: 10),
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

  /// Ligne de détail en lecture seule (pour l'email).
  Widget _detailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.outline),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Ligne de détail modifiable (pour le téléphone et la localisation).
  Widget _editableDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Future<void> Function(String) onSave,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.outline),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18),
          color: AppColors.primary,
          onPressed: () {
            _showEditDialog(context, label, value, onSave);
          },
        ),
      ],
    );
  }

  /// Dialogue d'édition pour modifier un champ texte.
  void _showEditDialog(
    BuildContext context,
    String label,
    String currentValue,
    Future<void> Function(String) onSave,
  ) {
    final controller = TextEditingController(
      text: currentValue == 'Non renseigné' ? '' : currentValue,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Modifier $label',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Entrez votre $label',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Annuler',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                await onSave(val);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Widget _alertRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required Future<void> Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _themeOption(
    BuildContext context, {
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
    required List<Color> gradientColors,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected ? AppColors.shadowGolden : [],
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: index == 0
                      ? AppColors.onSurface
                      : AppColors.inverseOnSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}
