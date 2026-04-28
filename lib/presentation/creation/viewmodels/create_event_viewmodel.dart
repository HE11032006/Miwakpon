import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/event_model.dart';
import '../../../data/services/event_service.dart';
import '../../../core/services/supabase_storage_service.dart';

/// ViewModel pour la création d'événements.
///
/// Responsabilités :
/// - Valider les champs du formulaire
/// - Appeler EventService.insert() pour créer l'événement
/// - Gérer les états loading/success/error
/// - Assurer la navigation après création réussie

class CreateEventViewModel extends ChangeNotifier {
  final EventService _eventService = EventService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  /// Valide les données de l'événement avant création.
  String? validateEventData({
    required String title,
    required String description,
    required DateTime? dateTime,
    required String location,
    required int maxParticipants,
  }) {
    // Validation du titre
    if (title.trim().isEmpty) {
      return 'Le titre est obligatoire';
    }
    if (title.trim().length < 3) {
      return 'Le titre doit contenir au moins 3 caractères';
    }

    // Validation de la description
    if (description.trim().isEmpty) {
      return 'La description est obligatoire';
    }
    if (description.trim().length < 10) {
      return 'La description doit contenir au moins 10 caractères';
    }

    // Validation de la date et heure
    if (dateTime == null) {
      return 'La date et l\'heure sont obligatoires';
    }
    if (dateTime.isBefore(DateTime.now())) {
      return 'La date de l\'événement doit être dans le futur';
    }

    // Validation du lieu
    if (location.trim().isEmpty) {
      return 'Le lieu est obligatoire';
    }
    if (location.trim().length < 2) {
      return 'Le lieu doit contenir au moins 2 caractères';
    }

    // Validation du nombre de participants
    if (maxParticipants <= 0) {
      return 'Le nombre de participants doit être supérieur à 0';
    }
    if (maxParticipants > 10000) {
      return 'Le nombre de participants ne peut pas dépasser 10 000';
    }

    return null; // Pas d'erreur
  }

  /// Crée un nouvel événement avec validation complète.
  Future<void> createEvent({
    required String title,
    required String description,
    required DateTime dateTime,
    required String location,
    String? organizerId, // Optionnel, sera récupéré depuis Supabase si non fourni
    String? imageUrl,
    int maxParticipants = 50,
  }) async {
    // Réinitialiser les états
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      // Récupérer l'UUID utilisateur depuis Supabase si non fourni
      if (organizerId == null || organizerId.isEmpty) {
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;
        
        if (user == null) {
          // Pour le développement, utiliser un UUID temporaire si pas authentifié
          debugPrint('Utilisateur non authentifié, utilisation UUID temporaire');
          organizerId = '00000000-0000-0000-0000-000000000001';
        } else {
          organizerId = user.id;
          debugPrint('UUID utilisateur récupéré: $organizerId');
        }
      } else {
        debugPrint('UUID utilisateur fourni: $organizerId');
      }

      // Validation finale de l'UUID
      if (organizerId.isEmpty) {
        _errorMessage = 'Erreur: UUID utilisateur invalide';
        return;
      }

      // Valider les données
      final validationError = validateEventData(
        title: title,
        description: description,
        dateTime: dateTime,
        location: location,
        maxParticipants: maxParticipants,
      );

      if (validationError != null) {
        _errorMessage = validationError;
        return;
      }

      // Debug: Afficher l'UUID qui sera envoyé
      debugPrint('UUID envoyé à Supabase: $organizerId');

      // Upload l'image vers Supabase Storage si une image locale est fournie
      String? publicImageUrl;
      if (imageUrl != null && imageUrl.startsWith('/')) {
        // Générer un ID temporaire pour l'événement
        final tempEventId = DateTime.now().millisecondsSinceEpoch.toString();
        publicImageUrl = await SupabaseStorageService.uploadEventImage(
          File(imageUrl), 
          tempEventId
        );
        
        if (publicImageUrl == null) {
          _errorMessage = 'Erreur lors de l\'upload de l\'image';
          return;
        }
        debugPrint('Image uploadée vers Supabase Storage: $publicImageUrl');
      } else {
        publicImageUrl = imageUrl;
      }

      // Créer le modèle d'événement
      final event = EventModel(
        id: '', // Supabase générera l'UUID
        title: title.trim(),
        description: description.trim(),
        dateTime: dateTime,
        location: location.trim(),
        organizerId: organizerId,
        imageUrl: publicImageUrl,
        maxParticipants: maxParticipants,
        createdAt: DateTime.now(),
      );

      // Debug: Afficher le payload qui sera envoyé
      final payload = event.toMap();
      debugPrint('Payload envoyé à Supabase: $payload');

      // Insérer dans Supabase via le service
      await _eventService.insert(payload);
      
      // Marquer comme succès
      _isSuccess = true;
      
    } catch (e) {
      // Gestion des erreurs détaillée
      if (e.toString().contains('duplicate key')) {
        _errorMessage = 'Un événement avec ce titre existe déjà';
      } else if (e.toString().contains('connection')) {
        _errorMessage = 'Erreur de connexion. Veuillez vérifier votre réseau';
      } else if (e.toString().contains('permission')) {
        _errorMessage = 'Vous n\'avez pas les permissions pour créer un événement';
      } else if (e.toString().contains('validation')) {
        _errorMessage = 'Erreur de validation des données';
      } else {
        _errorMessage = 'Une erreur est survenue: ${e.toString()}';
      }
      
      // En développement, afficher l'erreur complète
      debugPrint('CreateEvent Error: $e');
      
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Réinitialise le ViewModel pour une nouvelle création.
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();
  }
}
