import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Écran d'authentification Miwakpon
///
/// Design inspiré du mouvement impressionniste béninois :
/// - Palette ocre et indigo
/// - Typographie Newsreader pour les titres, Be Vietnam Pro pour les champs
/// - Champs avec style underline
/// - Bouton principal avec ombre dorée
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AuthViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                // Contenu principal
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 48,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo / Titre principal
                      _header(context, viewModel),
                      const SizedBox(height: 48),
                      // Formulaire
                      _form(context, viewModel),
                      const SizedBox(height: 24),
                      // Bouton de soumission
                      _submitButton(context, viewModel),
                      const SizedBox(height: 16),
                      // Lien pour basculer entre connexion/inscription
                      _modeToggle(context, viewModel),
                    ],
                  ),
                ),
                // Indicateur de chargement
                if (viewModel.isLoading)
                  const AppLoadingIndicator(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AuthViewModel viewModel) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            boxShadow: AppColors.shadowLight,
          ),
          child: const Icon(
            Icons.event_available,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Miwakpon',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontFamily: 'Newsreader',
                color: AppColors.primary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          viewModel.isLoginMode
              ? 'Connectez-vous à votre compte'
              : 'Créez votre compte',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _form(BuildContext context, AuthViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Champ Email
        Text(
          'Email',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: viewModel.emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !viewModel.isLoading,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'vous@exemple.com',
            hintStyle: const TextStyle(color: AppColors.textLight),
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
        ),
        const SizedBox(height: 20),

        // Champ Mot de passe
        Text(
          'Mot de passe',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: viewModel.passwordController,
          obscureText: true,
          textInputAction: viewModel.isLoginMode
              ? TextInputAction.done
              : TextInputAction.next,
          enabled: !viewModel.isLoading,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: const TextStyle(color: AppColors.textLight),
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onFieldSubmitted: (_) {
            if (viewModel.isLoginMode) {
              viewModel.submitForm(context);
            } else {
              FocusScope.of(context).nextFocus();
            }
          },
        ),

        // Champ Confirmation (uniquement pour l'inscription)
        if (!viewModel.isLoginMode) ...[
          const SizedBox(height: 20),
          Text(
            'Confirmer le mot de passe',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: viewModel.confirmPasswordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            enabled: !viewModel.isLoading,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(color: AppColors.textLight),
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onFieldSubmitted: (_) => viewModel.submitForm(context),
          ),
        ],

        // Message d'erreur
        if (viewModel.errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _submitButton(BuildContext context, AuthViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: AppColors.shadowGolden,
      ),
      child: ElevatedButton(
        onPressed: viewModel.isLoading ? null : () => viewModel.submitForm(context),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          disabledForegroundColor: AppColors.onPrimary.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0, // L'ombre est gérée par le Container
        ),
        child: Text(
          viewModel.isLoginMode ? 'SE CONNECTER' : "S'INSCRIRE",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _modeToggle(BuildContext context, AuthViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          viewModel.isLoginMode
              ? "Pas encore de compte ?"
              : "Déjà un compte ?",
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: viewModel.isLoading ? null : viewModel.toggleMode,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
          child: Text(
            viewModel.isLoginMode ? "S'inscrire" : "Se connecter",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}