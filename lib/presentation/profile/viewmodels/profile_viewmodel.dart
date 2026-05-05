import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileViewModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  String _displayName = '';
  String _username = '';
  String _phone = '';
  String? _avatarUrl;
  String _email = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get displayName => _displayName;
  String get username => _username;
  String get phone => _phone;
  String? get avatarUrl => _avatarUrl;
  String get email => _email;

  ProfileViewModel() {
    loadProfile();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        loadProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        _clearProfile();
      }
    });
  }

  void _clearProfile() {
    _displayName = '';
    _username = '';
    _phone = '';
    _avatarUrl = null;
    _email = '';
    notifyListeners();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _errorMessage = 'Utilisateur non connecte';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _email = user.email ?? '';

      // Recuperer les metadonnees du user
      final metadata = user.userMetadata;
      _displayName = metadata?['display_name'] ?? metadata?['username'] ?? 'Utilisateur';
      _username = metadata?['username'] ?? '';
      _phone = metadata?['phone'] ?? '';
      _avatarUrl = metadata?['avatar_url'];

      // Aussi verifier la table public.users
      try {
        final userData = await _supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (userData != null) {
          _username = userData['username'] ?? _username;
          _displayName = userData['display_name'] ?? _displayName;
          _avatarUrl = userData['avatar_url'] ?? _avatarUrl;
        }
      } catch (e) {
        debugPrint('Erreur lecture public.users: $e');
      }
    } catch (e) {
      debugPrint('ERREUR CHARGEMENT PROFIL: $e');
      _errorMessage = 'Impossible de charger les informations du profil.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Met a jour le nom d'utilisateur
  Future<bool> updateUsername(String newUsername) async {
    if (newUsername.trim().isEmpty || newUsername.trim().length < 3) {
      _errorMessage = 'Le nom d\'utilisateur doit contenir au moins 3 caracteres';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Verifier unicite
      final existing = await _supabase
          .from('users')
          .select('id')
          .eq('username', newUsername.trim())
          .neq('id', userId)
          .maybeSingle();

      if (existing != null) {
        _errorMessage = 'Ce nom d\'utilisateur est deja pris';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Mettre a jour auth metadata
      await _supabase.auth.updateUser(UserAttributes(
        data: {
          'username': newUsername.trim(),
          'display_name': newUsername.trim(),
        },
      ));

      // Mettre a jour public.users
      await _supabase.from('users').update({
        'username': newUsername.trim(),
        'display_name': newUsername.trim(),
      }).eq('id', userId);

      _username = newUsername.trim();
      _displayName = newUsername.trim();
      _successMessage = 'Nom d\'utilisateur mis a jour';
    } catch (e) {
      debugPrint('ERREUR UPDATE USERNAME: $e');
      _errorMessage = 'Impossible de mettre a jour le nom d\'utilisateur.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return true;
  }

  /// Met a jour le numero de telephone
  Future<bool> updatePhone(String newPhone) async {
    if (newPhone.trim().isEmpty) {
      _errorMessage = 'Veuillez saisir un numero de telephone';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _supabase.auth.updateUser(UserAttributes(
        data: {'phone': newPhone.trim()},
      ));

      _phone = newPhone.trim();
      _successMessage = 'Numero de telephone mis a jour';
    } catch (e) {
      debugPrint('ERREUR UPDATE USERNAME: $e');
      _errorMessage = 'Impossible de mettre a jour le nom d\'utilisateur.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return true;
  }

  /// Met a jour le mot de passe
  Future<bool> updatePassword(String newPassword) async {
    if (newPassword.length < 6) {
      _errorMessage = 'Le mot de passe doit contenir au moins 6 caracteres';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      _successMessage = 'Mot de passe mis a jour';
    } catch (e) {
      debugPrint('ERREUR UPDATE PASSWORD: $e');
      _errorMessage = 'Impossible de modifier le mot de passe pour le moment.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return true;
  }

  /// Upload une nouvelle photo de profil
  Future<void> pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );

      if (image == null) return;

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Upload vers Supabase Storage
      final fileName = 'avatar_$userId.jpg';
      final file = File(image.path);
      
      await _supabase.storage
          .from('avatars')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // Mettre a jour les metadonnees
      await _supabase.auth.updateUser(UserAttributes(
        data: {'avatar_url': publicUrl},
      ));

      // Mettre a jour public.users
      try {
        await _supabase.from('users').update({
          'avatar_url': publicUrl,
        }).eq('id', userId);
      } catch (e) {
        debugPrint('Erreur mise a jour avatar dans users: $e');
      }

      _avatarUrl = publicUrl;
      _successMessage = 'Photo de profil mise a jour';
    } catch (e) {
      debugPrint('ERREUR UPLOAD AVATAR: $e');
      _errorMessage = 'Echec de la mise a jour de la photo de profil.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
