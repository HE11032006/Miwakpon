import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/supabase_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoginMode = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => SupabaseConfig.isAuthenticated;
  bool get isLoginMode => _isLoginMode;

  void toggleMode() {
    _isLoginMode = !_isLoginMode;
    _errorMessage = null;
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    notifyListeners();
  }

  String? validateForm() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      return 'Veuillez saisir votre email';
    }
    if (!email.contains('@') || !email.contains('.')) {
      return 'Veuillez saisir un email valide';
    }
    if (password.isEmpty) {
      return 'Veuillez saisir votre mot de passe';
    }
    if (password.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }

    if (!_isLoginMode) {
      final confirmPassword = confirmPasswordController.text.trim();
      if (confirmPassword != password) {
        return 'Les mots de passe ne correspondent pas';
      }
    }

    return null;
  }

  /// Connexion avec email et mot de passe.
  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseConfig.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = _getUserFriendlyErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Inscription avec email et mot de passe.
  Future<bool> signUpWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseConfig.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': email.split('@')[0],
          'avatar_url': null,
        },
      );

      if (response.user != null) {
        _isLoading = false;
        notifyListeners();
        
        // Retourne true même si l'utilisateur doit confirmer son email
        // ou si l'inscription est réussie
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = _getUserFriendlyErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Soumettre le formulaire d'authentification
  Future<void> submitForm(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final validationError = validateForm();
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (_isLoginMode) {
      // Mode CONNEXION
      final success = await signInWithEmail(email, password);
      if (success && context.mounted) {
        // Nettoyer les champs
        emailController.clear();
        passwordController.clear();
        
        // Rediriger vers l'accueil
        context.go(AppConstants.homeRoute);
      }
    } else {
      // Mode INSCRIPTION
      final success = await signUpWithEmail(email, password);
      if (success && context.mounted) {
        // Afficher un message de succès
        _showSuccessMessage(context);
        
        // Nettoyer les champs
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        
        // Basculer automatiquement en mode connexion
        _isLoginMode = true;
        _errorMessage = null;
        notifyListeners();
        
        // Rediriger vers la page de connexion
        // On reste sur la même page mais en mode connexion
        // Le message de succès est déjà affiché
      }
    }
  }

  /// Afficher un message de succès après inscription
  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Compte créé avec succès ! Veuillez vous connecter.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Déconnexion.
  Future<void> signOut(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await SupabaseConfig.auth.signOut();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      _errorMessage = null;
      _isLoginMode = true;
      
      if (context.mounted) {
        context.go(AppConstants.loginRoute);
      }
    } catch (e) {
      _errorMessage = _getUserFriendlyErrorMessage(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Convertit les messages d'erreur techniques en messages compréhensibles
  String _getUserFriendlyErrorMessage(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Email ou mot de passe incorrect';
    }
    if (error.contains('User already registered')) {
      return 'Cet email est déjà utilisé';
    }
    if (error.contains('Email not confirmed')) {
      return 'Veuillez confirmer votre email avant de vous connecter';
    }
    if (error.contains('Password should be at least 6 characters')) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    if (error.contains('network')) {
      return 'Erreur de connexion. Vérifiez votre réseau';
    }
    return 'Une erreur est survenue. Veuillez réessayer';
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}