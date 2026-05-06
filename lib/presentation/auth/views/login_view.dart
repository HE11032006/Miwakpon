import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Ecran d'authentification Miwakpon
///
/// Design avec Ambient.png en fond, logo de l'app,
/// et formulaire de connexion/inscription par telephone.
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AuthViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              // Fond Ambient
              Positioned.fill(
                child: Image.asset(
                  'assets/images/ambient.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Overlay pour lisibilite
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.background.withValues(alpha: 0.7),
                        AppColors.background.withValues(alpha: 0.95),
                        AppColors.background,
                      ],
                      stops: const [0.0, 0.25, 0.45, 0.6],
                    ),
                  ),
                ),
              ),
              // Contenu principal
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      _header(context, viewModel),
                      const SizedBox(height: 40),
                      _form(context, viewModel),
                      const SizedBox(height: 24),
                      _submitButton(context, viewModel),
                      const SizedBox(height: 16),
                      _modeToggle(context, viewModel),
                    ],
                  ),
                ),
              ),
              // Indicateur de chargement
              if (viewModel.isLoading)
                const AppLoadingIndicator(),
            ],
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, AuthViewModel viewModel) {
    return Column(
      children: [
        // Logo de l'app
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: AppColors.shadowGolden,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(45),
            child: Image.asset(
              'assets/icons/sans_fond.jpg',
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Miwakpon',
          style: GoogleFonts.newsreader(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            viewModel.isLoginMode
                ? 'Connectez-vous pour profiter de moments uniques'
                : 'Creez votre compte pour profiter de moments uniques',
            style: GoogleFonts.beVietnamPro(
              fontSize: 15,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _form(BuildContext context, AuthViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Champ Username (inscription uniquement)
        if (!viewModel.isLoginMode) ...[
          _fieldLabel(context, 'Nom d\'utilisateur'),
          const SizedBox(height: 8),
          TextFormField(
            controller: viewModel.usernameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            enabled: !viewModel.isLoading,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration(
              hint: 'Ex: johndoe',
              icon: Icons.person_outline,
            ),
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: 20),
        ],

        // Champ Email
        _fieldLabel(context, 'Adresse email'),
        const SizedBox(height: 8),
        TextFormField(
          controller: viewModel.emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !viewModel.isLoading,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _inputDecoration(
            hint: 'votre@email.com',
            icon: Icons.email_outlined,
          ),
          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
        ),
        const SizedBox(height: 20),

        // Champ Mot de passe
        _fieldLabel(context, 'Mot de passe'),
        const SizedBox(height: 8),
        TextFormField(
          controller: viewModel.passwordController,
          obscureText: viewModel.obscurePassword,
          textInputAction: viewModel.isLoginMode
              ? TextInputAction.done
              : TextInputAction.next,
          enabled: !viewModel.isLoading,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _inputDecoration(
            hint: 'Minimum 6 caracteres',
            icon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                viewModel.obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textLight,
                size: 20,
              ),
              onPressed: viewModel.toggleObscurePassword,
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
          _fieldLabel(context, 'Confirmer le mot de passe'),
          const SizedBox(height: 8),
          TextFormField(
            controller: viewModel.confirmPasswordController,
            obscureText: viewModel.obscurePassword,
            textInputAction: TextInputAction.done,
            enabled: !viewModel.isLoading,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration(
              hint: 'Retapez votre mot de passe',
              icon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  viewModel.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textLight,
                  size: 20,
                ),
                onPressed: viewModel.toggleObscurePassword,
              ),
            ),
            onFieldSubmitted: (_) => viewModel.submitForm(context),
          ),
        ],

        _errorMessageWidget(viewModel),
      ],
    );
  }

  Widget _errorMessageWidget(AuthViewModel viewModel) {
    if (viewModel.errorMessage == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
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
    );
  }

  Widget _fieldLabel(BuildContext context, String label) {
    return Text(
      label,
      style: GoogleFonts.beVietnamPro(
        fontSize: 13,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textLight),
      prefixIcon: Icon(icon, color: AppColors.primary),
      suffixIcon: suffixIcon,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Widget _submitButton(BuildContext context, AuthViewModel viewModel) {
    final String buttonText = viewModel.isLoginMode ? 'SE CONNECTER' : "S'INSCRIRE";

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
          elevation: 0,
        ),
        child: Text(
          buttonText,
          style: GoogleFonts.beVietnamPro(
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
              : "Deja un compte ?",
          style: GoogleFonts.beVietnamPro(
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
            style: GoogleFonts.beVietnamPro(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}