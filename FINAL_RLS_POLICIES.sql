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

-- ÉTAPE 4: Vérification des politiques
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'events'
ORDER BY policyname;
