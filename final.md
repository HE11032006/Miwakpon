``-- Table des profils publics (visible par tous les membres)
CREATE TABLE public.users (
  id uuid references auth.users on delete cascade not null primary key,
  display_name text,
  avatar_url text,
  created_at timestamptz default now()
);

-- Table des événements
CREATE TABLE public.events (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  description text,
  date_time timestamptz,
  location text,
  organizer_id uuid references public.users(id) on delete cascade,
  image_url text,
  max_participants int4 default 50,
  created_at timestamptz default now()
);

-- Table des participations (Lien entre utilisateurs et événements)
CREATE TABLE public.participants (
  id uuid default gen_random_uuid() primary key,
  event_id uuid references public.events(id) on delete cascade not null,
  user_id uuid references public.users(id) on delete cascade not null,
  joined_at timestamptz default now()
);

-- ==========================================
-- 2. ACTIVATION DU TEMPS RÉEL (REALTIME)
-- ==========================================

-- Indispensable pour le flux d'événements du Membre 4
ALTER PUBLICATION supabase_realtime ADD TABLE public.events;

-- ==========================================
-- 3. AUTOMATISATION (TRIGGERS)
-- ==========================================
-- Ce code copie automatiquement les infos de auth.users vers public.users
-- lors de l'inscription (Membre 2) ou de la mise à jour du profil (Membre 1).

CREATE OR REPLACE FUNCTION public.handle_user_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO public.users (id, display_name, avatar_url)
    VALUES (
      new.id,
      new.raw_user_meta_data->>'display_name',
      new.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
  ELSIF (TG_OP = 'UPDATE') THEN
    UPDATE public.users
    SET display_name = new.raw_user_meta_data->>'display_name',
        avatar_url = new.raw_user_meta_data->>'avatar_url'
    WHERE id = new.id;
    RETURN NEW;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Déclencheur à l'inscription
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_user_changes();

-- Déclencheur à la modification du profil
CREATE TRIGGER on_auth_user_updated
  AFTER UPDATE ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_user_changes();

-- ==========================================
-- POLITIQUES RLS FINALES POUR MIWAKPON
-- ==========================================
-- Colonne UUID: organizer_id (confirmé dans code Flutter)

-- ÉTAPE 1: Activer RLS sur la table events
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

-- ÉTAPE 2: Supprimer toutes les politiques existantes sur events
DROP POLICY IF EXISTS "events_select_policy" ON public.events;
DROP POLICY IF EXISTS "events_insert_policy" ON public.events;
DROP POLICY IF EXISTS "events_update_policy" ON public.events;
DROP POLICY IF EXISTS "events_delete_policy" ON public.events;

-- ÉTAPE 3: Créer les politiques RLS finales
-- Politique SELECT: permettre aux utilisateurs authentifiés de lire tous les événements
CREATE POLICY "events_select_policy" ON public.events
    FOR SELECT USING (auth.role() = 'authenticated');

-- Politique INSERT: permettre aux utilisateurs authentifiés de créer leurs événements
CREATE POLICY "events_insert_policy" ON public.events
    FOR INSERT WITH CHECK (auth.uid() = organizer_id);

-- Politique UPDATE: permettre aux utilisateurs de modifier leurs propres événements
CREATE POLICY "events_update_policy" ON public.events
    FOR UPDATE USING (auth.uid() = organizer_id);

-- Politique DELETE: permettre aux utilisateurs de supprimer leurs propres événements
CREATE POLICY "events_delete_policy" ON public.events
    FOR DELETE USING (auth.uid() = organizer_id);

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

ALTER TABLE public.users ADD COLUMN username text;

```
