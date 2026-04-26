import 'package:flutter/material.dart';

import '../../../core/network/supabase_config.dart';

// TODO: Implémentation par Membre 2
// ViewModel pour l'authentification Supabase.
//
// Méthodes à implémenter :
// - signInWithEmail(String email, String password)
// - signUpWithEmail(String email, String password)
// - signOut()
// - Gestion des erreurs auth
//
// Utiliser SupabaseConfig.auth pour accéder au client GoTrue.

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => SupabaseConfig.isAuthenticated;

  /// Connexion avec email et mot de passe.
  Future<void> signInWithEmail(String email, String password) async {
    // TODO: Implémentation par Membre 2
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // await SupabaseConfig.auth.signInWithPassword(
      //   email: email,
      //   password: password,
      // );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Inscription avec email et mot de passe.
  Future<void> signUpWithEmail(String email, String password) async {
    // TODO: Implémentation par Membre 2
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // await SupabaseConfig.auth.signUp(
      //   email: email,
      //   password: password,
      // );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Déconnexion.
  Future<void> signOut() async {
    // TODO: Implémentation par Membre 2
    await SupabaseConfig.auth.signOut();
    notifyListeners();
  }
}
