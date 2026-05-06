import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ProfileViewModel>(
        builder: (context, profileVM, child) {
          if (profileVM.isLoading && profileVM.displayName.isEmpty) {
            return Center(
              child: SizedBox(
                width: 100,
                height: 2,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
            );
          }

          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/ambient.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header profil avec photo
                  _profileHeader(context, profileVM),
                const SizedBox(height: 24),
                // Infos du compte
                _accountSection(context, profileVM),
                const SizedBox(height: 16),
                // Parametres
                _settingsSection(context),
                const SizedBox(height: 16),
                // Deconnexion
                _logoutSection(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    ),
  );
}

  Widget _profileHeader(BuildContext context, ProfileViewModel profileVM) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.background,
          ],
        ),
      ),
      child: Column(
        children: [
          // Photo de profil avec bouton d'upload
          GestureDetector(
            onTap: () => profileVM.pickAndUploadAvatar(),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  backgroundImage: profileVM.avatarUrl != null
                      ? NetworkImage(profileVM.avatarUrl!)
                      : null,
                  child: profileVM.avatarUrl == null
                      ? const Icon(Icons.person,
                          size: 50, color: AppColors.primary)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Username
          Text(
            profileVM.username.isNotEmpty
                ? profileVM.username
                : profileVM.displayName,
            style: GoogleFonts.newsreader(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profileVM.phone.isNotEmpty
                ? profileVM.phone
                : 'Aucun telephone',
            style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountSection(BuildContext context, ProfileViewModel profileVM) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Mon compte',
              style: GoogleFonts.newsreader(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          _settingsTile(
            icon: Icons.person_outline,
            title: 'Nom d\'utilisateur',
            subtitle: profileVM.username.isNotEmpty
                ? profileVM.username
                : 'Non defini',
            onTap: () => _showEditDialog(
              context,
              title: 'Modifier le nom d\'utilisateur',
              initialValue: profileVM.username,
              onSave: (value) async {
                final success = await profileVM.updateUsername(value);
                if (success && context.mounted) {
                  _showSnackBar(context, 'Nom d\'utilisateur mis a jour');
                }
              },
            ),
          ),
          _thinDivider(),
          _settingsTile(
            icon: Icons.phone_outlined,
            title: 'Telephone',
            subtitle: profileVM.phone.isNotEmpty
                ? profileVM.phone
                : 'Non defini',
            onTap: () => _showEditDialog(
              context,
              title: 'Modifier le telephone',
              initialValue: profileVM.phone,
              keyboardType: TextInputType.phone,
              onSave: (value) async {
                final success = await profileVM.updatePhone(value);
                if (success && context.mounted) {
                  _showSnackBar(context, 'Telephone mis a jour');
                }
              },
            ),
          ),
          _thinDivider(),
          _settingsTile(
            icon: Icons.lock_outline,
            title: 'Mot de passe',
            subtitle: '**********',
            onTap: () => _showEditDialog(
              context,
              title: 'Modifier le mot de passe',
              initialValue: '',
              isPassword: true,
              onSave: (value) async {
                final success = await profileVM.updatePassword(value);
                if (success && context.mounted) {
                  _showSnackBar(context, 'Mot de passe mis a jour');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Parametres',
              style: GoogleFonts.newsreader(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          _settingsTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
            subtitle: 'Gerer vos notifications',
            onTap: () {
              _showSnackBar(context, 'Parametres de notifications a venir');
            },
          ),
          _thinDivider(),
          _settingsTile(
            icon: Icons.help_outline,
            title: 'Aide',
            subtitle: 'Centre d\'aide et FAQ',
            onTap: () {
              _showHelpDialog(context);
            },
          ),
          _thinDivider(),
          _settingsTile(
            icon: Icons.description_outlined,
            title: 'Conditions d\'utilisation',
            subtitle: 'Lire les conditions',
            onTap: () {
              _showTermsDialog(context);
            },
          ),
          _thinDivider(),
          _settingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Politique de confidentialite',
            subtitle: 'Vos donnees sont protegees',
            onTap: () {
              _showPrivacyDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _logoutSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(
                  'Deconnexion',
                  style: GoogleFonts.newsreader(fontWeight: FontWeight.w600),
                ),
                content: const Text(
                  'Voulez-vous vraiment vous deconnecter ?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<AuthViewModel>().signOut(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('Deconnecter'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.logout, size: 20),
          label: Text(
            'Se deconnecter',
            style: GoogleFonts.beVietnamPro(
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.beVietnamPro(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.beVietnamPro(
          fontSize: 13,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.onSurfaceVariant, size: 20),
    );
  }

  Widget _thinDivider() {
    return const Divider(
      height: 1,
      indent: 64,
      endIndent: 16,
      color: Color(0xFFF0EDEC),
    );
  }

  void _showEditDialog(
    BuildContext context, {
    required String title,
    required String initialValue,
    required Future<void> Function(String value) onSave,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.newsreader(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: isPassword
                ? 'Nouveau mot de passe (min. 6 caracteres)'
                : 'Saisir la nouvelle valeur',
            hintStyle: const TextStyle(color: AppColors.textLight),
            enabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onSave(controller.text);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Centre d\'aide',
          style: GoogleFonts.newsreader(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Miwakpon est une application de gestion d\'evenements communautaires au Benin.',
              style: GoogleFonts.beVietnamPro(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Pour toute question ou probleme, contactez-nous a :',
              style: GoogleFonts.beVietnamPro(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 8),
            Text(
              'eulogemn@gmail.com',
              style: GoogleFonts.beVietnamPro(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Conditions d\'utilisation',
          style: GoogleFonts.newsreader(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Text(
            'En utilisant Miwakpon, vous acceptez les conditions suivantes :\n\n'
            '1. Vous devez avoir au moins 13 ans pour utiliser cette application.\n\n'
            '2. Vous etes responsable du contenu que vous publiez.\n\n'
            '3. Les evenements doivent respecter les lois en vigueur au Benin.\n\n'
            '4. Nous nous reservons le droit de supprimer tout contenu inapproprie.\n\n'
            '5. L\'application est fournie "telle quelle" sans garantie.\n\n'
            'Derniere mise a jour : Mai 2026',
            style: GoogleFonts.beVietnamPro(fontSize: 13, height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Politique de confidentialite',
          style: GoogleFonts.newsreader(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Chez Miwakpon, la protection de vos donnees est une priorite.\n\n'
            'Donnees collectees :\n'
            '- Nom d\'utilisateur et numero de telephone\n'
            '- Photo de profil (optionnelle)\n'
            '- Evenements crees et participations\n\n'
            'Utilisation des donnees :\n'
            '- Gestion de votre compte\n'
            '- Affichage des evenements\n'
            '- Amelioration de l\'experience utilisateur\n\n'
            'Vos donnees ne sont jamais vendues a des tiers.\n\n'
            'Pour toute demande de suppression, contactez eulogemn@gmail.com.',
            style: GoogleFonts.beVietnamPro(fontSize: 13, height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}