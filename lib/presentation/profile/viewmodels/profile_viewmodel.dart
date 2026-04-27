import 'package:flutter/material.dart';

import '../../../core/network/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ViewModel pour le profil utilisateur.
//
// Responsabilités :
// - Charger les informations du profil depuis Supabase
// - Mettre à jour le profil (nom, avatar, téléphone, localisation)
// - Gérer les préférences d'alertes (sauvegardées dans user_metadata)
// - Gérer la sélection du thème (clair/sombre)
// - Gérer la déconnexion (logique à compléter par le Membre 1)

class ProfileViewModel extends ChangeNotifier {
  String? _displayName;
  String? _email;
  String? _avatarUrl;
  String? _phone;
  String? _location;
  bool _isLoading = true;

  // --- États des Alertes ---
  bool _newCommissions = true;
  bool _exhibitionUpdates = true;
  bool _securityAlerts = false;

  // --- Thème sélectionné (0 = Lumière Aube, 1 = Ombre Crépuscule) ---
  int _selectedTheme = 0;

  // --- Getters ---
  String? get displayName => _displayName;
  String? get email => _email;
  String? get avatarUrl => _avatarUrl;
  String? get phone => _phone;
  String? get location => _location;
  bool get isLoading => _isLoading;

  bool get newCommissions => _newCommissions;
  bool get exhibitionUpdates => _exhibitionUpdates;
  bool get securityAlerts => _securityAlerts;

  int get selectedTheme => _selectedTheme;
  bool get isDarkMode => _selectedTheme == 1;

  ProfileViewModel() {
    _loadProfile();
  }

  void _loadProfile() {
    final user = SupabaseConfig.currentUser;
    if (user != null) {
      _email = user.email;
      final metadata = user.userMetadata;
      _displayName = metadata?['display_name'] as String?;
      _avatarUrl = metadata?['avatar_url'] as String?;
      _phone = metadata?['phone'] as String?;
      _location = metadata?['location'] as String?;

      // Charger les préférences d'alertes depuis les métadonnées
      _newCommissions = metadata?['alert_commissions'] as bool? ?? true;
      _exhibitionUpdates = metadata?['alert_exhibitions'] as bool? ?? true;
      _securityAlerts = metadata?['alert_security'] as bool? ?? false;

      // Charger le thème sélectionné
      _selectedTheme = metadata?['selected_theme'] as int? ?? 0;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Met à jour le profil (nom et/ou avatar).
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

  /// Met à jour le numéro de téléphone.
  Future<void> updatePhone(String phone) async {
    try {
      _phone = phone;
      await SupabaseConfig.auth.updateUser(
        UserAttributes(data: {'phone': phone}),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur updatePhone: $e');
    }
  }

  /// Met à jour la localisation.
  Future<void> updateLocation(String location) async {
    try {
      _location = location;
      await SupabaseConfig.auth.updateUser(
        UserAttributes(data: {'location': location}),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur updateLocation: $e');
    }
  }

  // ======================== ALERTES ========================

  /// Active/désactive l'alerte "Nouvelles Commissions".
  Future<void> toggleNewCommissions(bool value) async {
    _newCommissions = value;
    notifyListeners();
    await _saveAlertPreferences();
  }

  /// Active/désactive l'alerte "Mises à jour Expositions".
  Future<void> toggleExhibitionUpdates(bool value) async {
    _exhibitionUpdates = value;
    notifyListeners();
    await _saveAlertPreferences();
  }

  /// Active/désactive l'alerte "Alertes Sécurité".
  Future<void> toggleSecurityAlerts(bool value) async {
    _securityAlerts = value;
    notifyListeners();
    await _saveAlertPreferences();
  }

  /// Sauvegarde les préférences d'alertes dans Supabase user_metadata.
  Future<void> _saveAlertPreferences() async {
    try {
      await SupabaseConfig.auth.updateUser(
        UserAttributes(data: {
          'alert_commissions': _newCommissions,
          'alert_exhibitions': _exhibitionUpdates,
          'alert_security': _securityAlerts,
        }),
      );
    } catch (e) {
      debugPrint('Erreur sauvegarde alertes: $e');
    }
  }

  // ======================== THÈME ========================

  /// Sélectionne le thème (0 = Lumière Aube, 1 = Ombre Crépuscule).
  Future<void> setTheme(int index) async {
    _selectedTheme = index;
    notifyListeners();
    try {
      await SupabaseConfig.auth.updateUser(
        UserAttributes(data: {'selected_theme': index}),
      );
    } catch (e) {
      debugPrint('Erreur sauvegarde thème: $e');
    }
  }

  // ======================== DÉCONNEXION ========================

  /// Déconnexion.
  /// TODO: Logique à compléter par le Membre 1.
  Future<void> signOut() async {
    await SupabaseConfig.auth.signOut();
    notifyListeners();
  }
}
