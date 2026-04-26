# Configuration de la Base de Données Supabase (Miwakpon)

Salut l'équipe ! 👋 

J'ai préparé le script SQL complet pour initialiser notre base de données Supabase. Ce script crée toutes les tables dont nous aurons besoin pour nos différentes tâches (Profils, Événements, Participants) et met en place les liaisons automatiques (Triggers) avec l'authentification.

**Membre 2** : Quand tu feras l'inscription (`auth.users`), ce script s'assurera que le profil public du nouvel inscrit est automatiquement créé.
**Membre 3** : La table `events` est prête à recevoir tes insertions depuis le formulaire de création.
**Membres 4 & 5** : Les relations sont en place ! Vous pourrez récupérer facilement l'auteur d'un événement ou la liste des participants pour le Feed et la page Détails.

---

### Instructions d'installation

1. Connectez-vous au Dashboard de notre projet Supabase.
2. Allez dans le **SQL Editor** (l'icône `</>` dans le menu de gauche).
3. Cliquez sur **New Query**.
4. Copiez-collez l'intégralité du script ci-dessous.
5. Cliquez sur **Run** (en bas à droite).

---

### Le Script SQL Complet

```sql
-- ==========================================
-- 1. CREATION DES TABLES
-- ==========================================

-- Table des profils publics (visible par tous les membres)
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
```

Bon code à tous ! On va faire une appli incroyable.
