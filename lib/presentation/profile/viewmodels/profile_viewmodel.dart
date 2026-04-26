import 'package:flutter/material.dart';

import '../../../core/network/supabase_config.dart';

// ViewModel pour le profil utilisateur.
//
// Responsabilités :
// - Charger les informations du profil depuis Supabase
// - Mettre à jour le profil (nom, avatar)
// - Gérer la déconnexion

class ProfileViewModel extends ChangeNotifier {
  String? _displayName;
  String? _email;
  String? _avatarUrl;
  bool _isLoading = true;

  String? get displayName => _displayName;
  String? get email => _email;
  String? get avatarUrl => _avatarUrl;
  bool get isLoading => _isLoading;

  ProfileViewModel() {
    _loadProfile();
  }

  void _loadProfile() {
    final user = SupabaseConfig.currentUser;
    if (user != null) {
      _email = user.email;
      _displayName = user.userMetadata?['display_name'] as String?;
      _avatarUrl = user.userMetadata?['avatar_url'] as String?;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Met à jour le profil.
  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    // TODO: Implémentation par Membre 1
  }

  /// Déconnexion.
  Future<void> signOut() async {
    await SupabaseConfig.auth.signOut();
    notifyListeners();
  }
}
