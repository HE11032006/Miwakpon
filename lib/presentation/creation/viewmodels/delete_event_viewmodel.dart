import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/services/event_service.dart';
import '../../../core/services/supabase_storage_service.dart';

/// ViewModel pour la suppression d'événements
class DeleteEventViewModel extends ChangeNotifier {
  final EventService _eventService = EventService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  /// Supprime un événement avec vérification de sécurité
  Future<void> deleteEvent(String eventId, String? imageUrl) async {
    // Réinitialiser les états
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      // Récupérer l'UUID utilisateur actuel
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser == null) {
        _errorMessage = 'Utilisateur non authentifié';
        return;
      }

      // Récupérer l'événement pour vérifier que l'utilisateur est bien l'organisateur
      final eventData = await supabase
          .from('events')
          .select('organizer_id')
          .eq('id', eventId)
          .single();

      // Vérifier que l'utilisateur est bien l'organisateur
      if (eventData['organizer_id'] != currentUser.id) {
        _errorMessage = 'Vous n\'êtes pas autorisé à supprimer cet événement';
        return;
      }

      // Supprimer l'image si elle existe
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await SupabaseStorageService.deleteEventImage(imageUrl);
      }

      // Supprimer l'événement
      await _eventService.delete(eventId);
      
      debugPrint('Événement supprimé avec succès: $eventId');
      _isSuccess = true;
      
    } catch (e) {
      if (e.toString().contains('permission')) {
        _errorMessage = 'Permission refusée pour supprimer cet événement';
      } else if (e.toString().contains('connection')) {
        _errorMessage = 'Erreur de connexion. Veuillez vérifier votre réseau';
      } else {
        _errorMessage = 'Erreur lors de la suppression: ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
