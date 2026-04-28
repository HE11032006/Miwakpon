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

        return Scaffold(
          body: Stack(
            children: [
              // ======================== BACKGROUNDS ========================
              Positioned.fill(
                child: Image.asset(
                  'assets/gradient/background.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        AppColors.background.withValues(alpha: 0.8),
                        AppColors.background,
                      ],
                    ),
                  ),
                ),
              ),
              // Gradient décoratif en haut à droite
              Positioned(
                top: -100,
                right: -100,
                width: 400,
                height: 400,
                child: Opacity(
                  opacity: 0.35,
                  child: Image.asset(
                    'assets/gradient/Gradient.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // ======================== CONTENT ========================
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),

                      // ======================== AVATAR ========================
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  blurRadius: 30,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 64,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              backgroundImage: viewModel.avatarUrl != null
                                  ? NetworkImage(viewModel.avatarUrl!)
                                  : null,
                              child: viewModel.avatarUrl == null
                                  ? const Icon(Icons.person,
                                      size: 64, color: AppColors.primary)
                                  : null,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ======================== NOM & BIO ========================
                      Text(
                        viewModel.displayName ?? 'Artisan Béninois',
                        style: GoogleFonts.newsreader(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Maître Artisan • Cotonou, Bénin',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Passionné par l\'artisanat traditionnel et l\'innovation numérique. Créateur d\'expériences uniques.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ======================== CARDS SECTIONS ========================
                      _sectionCard(
                        context,
                        icon: Icons.person_outline,
                        title: 'Mon Profil',
                        child: Column(
                          children: [
                            _detailRow(
                              context,
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: viewModel.email ?? 'Non renseigné',
                            ),
                            const _CustomDivider(),
                            _editableDetailRow(
                              context,
                              icon: Icons.phone_outlined,
                              label: 'Téléphone',
                              value: viewModel.phone ?? 'Non renseigné',
                              onSave: (val) => viewModel.updatePhone(val),
                            ),
                          ],
                        ),
                      ),

                      _sectionCard(
                        context,
                        icon: Icons.settings_outlined,
                        title: 'Paramètres',
                        child: Column(
                          children: [
                            _alertRow(
                              context,
                              title: 'Notifications',
                              subtitle: 'Alertes en temps réel',
                              value: viewModel.newCommissions,
                              onChanged: viewModel.toggleNewCommissions,
                            ),
                            const _CustomDivider(),
                            _alertRow(
                              context,
                              title: 'Mode sombre',
                              subtitle: 'Lumière Crépuscule',
                              value: viewModel.selectedTheme == 1,
                              onChanged: (val) => viewModel.setTheme(val ? 1 : 0),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ======================== DÉCONNEXION ========================
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.shadowLight,
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            await viewModel.signOut();
                            if (context.mounted) {
                              context.go(AppConstants.loginRoute);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.error,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: AppColors.error.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          child: Text(
                            'Se déconnecter',
                            style: GoogleFonts.beVietnamPro(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CustomDivider extends StatelessWidget {
  const _CustomDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.outline.withValues(alpha: 0),
            AppColors.outline.withValues(alpha: 0.1),
            AppColors.outline.withValues(alpha: 0),
          ],
        ),
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
