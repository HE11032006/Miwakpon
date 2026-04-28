-- ==========================================
-- CONFIGURATION SUPABASE STORAGE POUR MIWAKPON
-- ==========================================
-- À exécuter dans le SQL Editor de Supabase

-- Créer un bucket pour les images d'événements
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'event-images',
    'event-images',
    true,
    5242880, -- 5MB
    ARRAY['image/jpeg', 'image/png', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- Politique pour permettre aux utilisateurs authentifiés d'uploader des images
CREATE POLICY "Users can upload event images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'event-images' AND 
        auth.role() = 'authenticated'
    );

-- Politique pour permettre à tout le monde de voir les images d'événements
CREATE POLICY "Event images are public" ON storage.objects
    FOR SELECT USING (bucket_id = 'event-images');

-- Politique pour permettre aux utilisateurs de modifier leurs propres images
CREATE POLICY "Users can update their event images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'event-images' AND 
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Politique pour permettre aux utilisateurs de supprimer leurs propres images
CREATE POLICY "Users can delete their event images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'event-images' AND 
        auth.uid()::text = (storage.foldername(name))[1]
    );
