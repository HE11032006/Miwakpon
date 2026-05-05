import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/supabase_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  final usernameController = TextEditingController();
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
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    notifyListeners();
  }

  String? validateForm() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      return 'Veuillez saisir votre adresse email';
    }
    if (!email.contains('@') || !email.contains('.')) {
      return 'Veuillez saisir une adresse email valide';
    }
    if (password.isEmpty) {
      return 'Veuillez saisir votre mot de passe';
    }
    if (password.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caracteres';
    }

    if (!_isLoginMode) {
      final username = usernameController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (username.isEmpty) {
        return 'Veuillez saisir un nom d\'utilisateur';
      }
      if (username.length < 3) {
        return 'Le nom d\'utilisateur doit contenir au moins 3 caracteres';
      }
      if (confirmPassword != password) {
        return 'Les mots de passe ne correspondent pas';
      }
    }

    return null;
  }

  /// Verifie si le username existe deja
  Future<bool> _isUsernameAvailable(String username) async {
    try {
      final result = await SupabaseConfig.client
          .from('users')
          .select('id')
          .eq('username', username)
          .maybeSingle();
      return result == null;
    } catch (e) {
      debugPrint('Erreur verification username: $e');
      return true; // En cas d'erreur on laisse passer
    }
  }

  /// Connexion avec email et mot de passe.
  Future<bool> signIn(String email, String password) async {
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
  Future<bool> signUp(String email, String password, String username) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Verifier si le username est disponible
      final available = await _isUsernameAvailable(username);
      if (!available) {
        _errorMessage = 'Ce nom d\'utilisateur est deja pris';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await SupabaseConfig.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': username,
          'username': username,
        },
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
      final success = await signIn(email, password);
      if (success && context.mounted) {
        emailController.clear();
        passwordController.clear();
        context.go(AppConstants.homeRoute);
      }
    } else {
      final username = usernameController.text.trim();
      final success = await signUp(email, password, username);
      if (success && context.mounted) {
        _showSuccessMessage(context);
        usernameController.clear();
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        _isLoginMode = true;
        _errorMessage = null;
        notifyListeners();
      }
    }
  }

  /// Afficher un message de succes apres inscription
  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Compte cree avec succes ! Veuillez verifier vos mails si necessaire.',
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

  /// Deconnexion.
  Future<void> signOut(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await SupabaseConfig.auth.signOut();
      usernameController.clear();
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

  /// Convertit les messages d'erreur techniques en messages comprehensibles
  String _getUserFriendlyErrorMessage(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Email ou mot de passe incorrect';
    }
    if (error.contains('User already registered')) {
      return 'Cet email est deja utilise';
    }
    if (error.contains('Email not confirmed')) {
      return 'Votre email n\'est pas encore confirme';
    }
    if (error.contains('Password should be at least 6 characters')) {
      return 'Le mot de passe doit contenir au moins 6 caracteres';
    }
    if (error.contains('network')) {
      return 'Erreur de connexion. Verifiez votre reseau';
    }
    return 'Une erreur est survenue. Veuillez reessayer';
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}