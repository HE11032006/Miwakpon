import 'package:flutter/material.dart';

import '../../../core/network/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ViewModel pour le profil utilisateur.
//
// Responsabilités :
// - Charger les informations du profil depuis Supabase
// - Mettre à jour le profil (nom, avatar)
// - Gérer les états des alertes (switches)
// - Gérer la sélection du thème
// - Gérer la déconnexion

class ProfileViewModel extends ChangeNotifier {
  String? _displayName;
  String? _email;
  String? _avatarUrl;
  bool _isLoading = true;

  // --- États des Alertes ---
  bool _newCommissions = true;
  bool _exhibitionUpdates = true;
  bool _securityAlerts = false;

  // --- Thème sélectionné (0 = clair, 1 = sombre) ---
  int _selectedTheme = 0;

  // --- Getters ---
  String? get displayName => _displayName;
  String? get email => _email;
  String? get avatarUrl => _avatarUrl;
  bool get isLoading => _isLoading;

  bool get newCommissions => _newCommissions;
  bool get exhibitionUpdates => _exhibitionUpdates;
  bool get securityAlerts => _securityAlerts;

  int get selectedTheme => _selectedTheme;

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
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> data = {};
      if (displayName != null) {
        data['display_name'] = displayName;
        _displayName = displayName;
      }
      if (avatarUrl != null) {
        data['avatar_url'] = avatarUrl;
        _avatarUrl = avatarUrl;
      }

      if (data.isNotEmpty) {
        await SupabaseConfig.auth.updateUser(
          UserAttributes(data: data),
        );
      }
    } catch (e) {
      debugPrint('Erreur updateProfile: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Active/désactive une alerte.
  void toggleNewCommissions(bool value) {
    _newCommissions = value;
    notifyListeners();
  }

  void toggleExhibitionUpdates(bool value) {
    _exhibitionUpdates = value;
    notifyListeners();
  }

  void toggleSecurityAlerts(bool value) {
    _securityAlerts = value;
    notifyListeners();
  }

  /// Sélectionne le thème (0 = clair, 1 = sombre).
  void setTheme(int index) {
    _selectedTheme = index;
    notifyListeners();
  }

  /// Déconnexion.
  Future<void> signOut() async {
    await SupabaseConfig.auth.signOut();
    notifyListeners();
  }
}
