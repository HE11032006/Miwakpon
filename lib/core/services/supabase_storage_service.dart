import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service pour l'upload de fichiers vers Supabase Storage
class SupabaseStorageService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Upload une image d'événement vers Supabase Storage
  /// Retourne l'URL publique de l'image ou null en cas d'erreur
  static Future<String?> uploadEventImage(File imageFile, String eventId) async {
    try {
      final fileName = 'event-$eventId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await _client.storage
          .from('event-images')
          .upload(fileName, imageFile);
      
      // Récupérer l'URL publique
      final publicUrl = _client.storage
          .from('event-images')
          .getPublicUrl(fileName);
      
      debugPrint('Image uploadée avec succès: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('Erreur upload image: $e');
      return null;
    }
  }

  /// Supprimer une image d'événement
  static Future<void> deleteEventImage(String imageUrl) async {
    try {
      final fileName = imageUrl.split('/').last;
      await _client.storage
          .from('event-images')
          .remove([fileName]);
      
      debugPrint('Image supprimée: $fileName');
    } catch (e) {
      debugPrint('Erreur suppression image: $e');
    }
  }
}
