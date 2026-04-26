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
  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Initialiser le controller si pas en édition
        if (!_isEditing && viewModel.displayName != null) {
          _nameController.text = viewModel.displayName!;
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
              
              // Email (lecture seule)
              Text(
                viewModel.email ?? 'Email inconnu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),

              // Formulaire de nom
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: AppColors.shadowLight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations personnelles',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom complet',
                        border: UnderlineInputBorder(),
                      ),
                      onChanged: (_) {
                        if (!_isEditing) setState(() => _isEditing = true);
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await viewModel.updateProfile(
                              displayName: _nameController.text,
                            );
                            if (context.mounted) {
                              setState(() => _isEditing = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profil mis à jour')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Sauvegarder les modifications'),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // NOTE: Le bouton de déconnexion est à la charge du Membre 1
            ],
          ),
        );
      },
    );
  }
}
