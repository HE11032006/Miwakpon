import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/supabase_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();

  bool _isLoginMode = true;
  bool _otpSent = false;
  bool _otpVerified = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => SupabaseConfig.isAuthenticated;
  bool get isLoginMode => _isLoginMode;
  bool get otpSent => _otpSent;
  bool get otpVerified => _otpVerified;

  void toggleMode() {
    _isLoginMode = !_isLoginMode;
    _errorMessage = null;
    _otpSent = false;
    _otpVerified = false;
    usernameController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    otpController.clear();
    notifyListeners();
  }

  String? validateForm() {
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (phone.isEmpty) {
      return 'Veuillez saisir votre numero de telephone';
    }
    if (phone.length < 8) {
      return 'Le numero de telephone doit contenir au moins 8 chiffres';
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

  /// Connexion avec telephone et mot de passe.
  /// On utilise le telephone comme identifiant email factice (phone@miwakpon.app)
  Future<bool> signInWithPhone(String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // On cree un email factice a partir du numero de telephone
      final fakeEmail = '${phone.replaceAll('+', '')}@miwakpon.app';
      
      final response = await SupabaseConfig.auth.signInWithPassword(
        email: fakeEmail,
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

  /// Inscription avec telephone et mot de passe.
  Future<bool> signUpWithPhone(String phone, String password, String username) async {
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

      final fakeEmail = '${phone.replaceAll('+', '')}@miwakpon.app';
      
      final response = await SupabaseConfig.auth.signUp(
        email: fakeEmail,
        password: password,
        data: {
          'display_name': username,
          'username': username,
          'phone': phone,
          'avatar_url': null,
        },
      );

      if (response.user != null) {
        // Mettre a jour le username dans public.users
        try {
          await SupabaseConfig.client
              .from('users')
              .update({'username': username, 'display_name': username})
              .eq('id', response.user!.id);
        } catch (e) {
          debugPrint('Erreur mise a jour username dans public.users: $e');
        }

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

    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (_isLoginMode) {
      final success = await signInWithPhone(phone, password);
      if (success && context.mounted) {
        phoneController.clear();
        passwordController.clear();
        context.go(AppConstants.homeRoute);
      }
    } else {
      final username = usernameController.text.trim();
      final success = await signUpWithPhone(phone, password, username);
      if (success && context.mounted) {
        _showSuccessMessage(context);
        usernameController.clear();
        phoneController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        otpController.clear();
        _isLoginMode = true;
        _errorMessage = null;
        _otpSent = false;
        _otpVerified = false;
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
                'Compte cree avec succes ! Veuillez vous connecter.',
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
      phoneController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      otpController.clear();
      _errorMessage = null;
      _isLoginMode = true;
      _otpSent = false;
      _otpVerified = false;
      
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
      return 'Numero de telephone ou mot de passe incorrect';
    }
    if (error.contains('User already registered')) {
      return 'Ce numero de telephone est deja utilise';
    }
    if (error.contains('Email not confirmed')) {
      return 'Votre compte n\'est pas encore confirme';
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
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    super.dispose();
  }
}