# Miwakpon

Application mobile de gestion d'evenements en temps reel, construite avec Flutter et Supabase. Le design s'inspire du mouvement impressionniste beninois (palette ocre, indigo, toile canvas).

Ce repository contient le squelette du projet. Chaque membre de l'equipe a un dossier dedie dans lequel il doit travailler. La configuration globale (theme, routeur, Supabase, providers) est deja en place -- vous n'avez pas besoin d'y toucher sauf si vous avez une bonne raison.

---

## Table des matieres

1. [Installation](#installation)
2. [Architecture du projet](#architecture-du-projet)
3. [Convention Git](#convention-git)
4. [Configuration Supabase](#configuration-supabase)
5. [Comment le temps reel fonctionne](#comment-le-temps-reel-fonctionne)
6. [Repartition des taches par membre](#repartition-des-taches-par-membre)
7. [Widgets partages](#widgets-partages)
8. [FAQ](#faq)

---

## Installation

Prerequis : Flutter SDK >= 3.10.4, un editeur (VS Code ou Android Studio), Git.

```bash
git clone <url-du-repo>
cd benin-impressionist-sync
flutter pub get
flutter run
```

L'application demarre sur le Splash Screen puis redirige vers la page de login. Pour l'instant les ecrans affichent des placeholders -- c'est normal, c'est a vous de les remplir.

---

## Architecture du projet

Le projet suit le pattern **Clean Architecture** avec **MVVM** et **Provider** pour la gestion d'etat.

```
lib/
  core/
    constants/       -> Constantes globales (noms de tables, routes, durees)
    theme/           -> Palette de couleurs et ThemeData
    network/         -> Client Supabase et service de base Realtime
    utils/           -> Routeur GoRouter

  domain/
    entities/        -> Entites metier pures (pas de dependance framework)
    repositories_interfaces/  -> Contrats abstraits

  data/
    models/          -> Modeles avec fromMap/toMap (serialisation Supabase)
    services/        -> Services concrets (acces Supabase + Realtime)
    repositories_impl/  -> Implementation des contrats du domain

  presentation/
    splash/          -> Ecran de demarrage
    auth/            -> Connexion / Inscription (Membre 2)
    home/            -> Feed des evenements (Membre 4)
    creation/        -> Formulaire de creation (Membre 3)
    detail/          -> Detail d'un evenement (Membre 4/5)
    participation/   -> Liste des participants (Membre 5)
    profile/         -> Profil et parametres (Membre 1)
    widgets/         -> Composants reutilisables pour tout le monde
```

Chaque dossier dans `presentation/` contient deux sous-dossiers :
- `views/` : le widget Flutter (la UI)
- `viewmodels/` : la logique metier (ChangeNotifier pour Provider)

Ne creez pas de nouveaux dossiers a la racine de `presentation/` sans en discuter avec l'equipe.

---

## Convention Git

Regles a respecter imperativement :

1. **Ne travaillez jamais directement sur `main`.** Creez toujours une branche.
2. Nommez vos branches comme suit : `feat/nom-de-la-feature`, `fix/description-du-bug`, `chore/tache-technique`.
3. Messages de commit en francais, prefixes par le type : `feat:`, `fix:`, `chore:`, `add:`, etc.
4. Un commit = une modification logique. Ne commitez pas tout d'un coup.
5. Mergez sur `main` uniquement quand votre code compile sans erreur (`flutter analyze` doit passer).

Exemple de workflow :

```bash
git checkout -b feat/formulaire-login
# ... vous codez ...
git add .
git commit -m "feat: ajout du formulaire de connexion avec validation email"
# verifiez que ca compile
flutter analyze
# si tout est bon
git checkout main
git merge feat/formulaire-login
```

---

## Configuration Supabase

Avant de lancer l'application, chaque membre doit configurer les cles Supabase dans le fichier `lib/core/network/supabase_config.dart` :

```dart
static const String _supabaseUrl = 'VOTRE_SUPABASE_URL';
static const String _supabaseAnonKey = 'VOTRE_SUPABASE_ANON_KEY';
```

Remplacez ces valeurs par les cles de notre projet Supabase (demandez-les au Membre 1 si vous ne les avez pas).

**Attention** : ne commitez jamais les cles en dur dans le repo public. Si on passe sur un `.env`, on fera la migration ensemble.

### Tables Supabase attendues

Le schema de la base de donnees doit contenir au minimum ces tables :

**Table `events`** :
| Colonne | Type | Description |
|---------|------|-------------|
| id | uuid (PK) | Identifiant unique, genere par Supabase |
| title | text | Titre de l'evenement |
| description | text | Description detaillee |
| date_time | timestamptz | Date et heure de l'evenement |
| location | text | Lieu |
| organizer_id | uuid (FK -> auth.users) | Createur de l'evenement |
| image_url | text (nullable) | URL de l'image |
| max_participants | int4 | Nombre max de participants (defaut: 50) |
| created_at | timestamptz | Date de creation |

**Table `participants`** :
| Colonne | Type | Description |
|---------|------|-------------|
| id | uuid (PK) | Identifiant unique |
| event_id | uuid (FK -> events) | Evenement concerne |
| user_id | uuid (FK -> auth.users) | Utilisateur participant |
| joined_at | timestamptz | Date d'inscription |

Activez le **Realtime** sur la table `events` dans le dashboard Supabase (Database > Replication > Source > cochez `events`).

---

## Comment le temps reel fonctionne

Le projet utilise un systeme de Stream pour recevoir les mises a jour en temps reel depuis Supabase. Voici comment ca marche, parce que c'est important que tout le monde comprenne le mecanisme :

1. `BaseRealtimeService` (dans `core/network/`) est une classe abstraite qui gere la souscription a une table Supabase. Elle expose un `Stream<List<T>>`.

2. `EventService` (dans `data/services/`) herite de `BaseRealtimeService` et specifie la table `events`. C'est lui qui fait le pont entre Supabase et le reste de l'app.

3. `HomeViewModel` (dans `presentation/home/viewmodels/`) s'abonne au stream de `EventService`. A chaque fois qu'un evenement est cree, modifie ou supprime dans Supabase, le stream emet la nouvelle liste et la UI se met a jour automatiquement.

En pratique, dans votre View, vous faites ca :

```dart
// Dans votre widget
Consumer<HomeViewModel>(
  builder: (context, viewModel, child) {
    if (viewModel.isLoading) {
      return const AppLoadingIndicator();
    }
    if (viewModel.errorMessage != null) {
      return AppErrorWidget(message: viewModel.errorMessage!);
    }
    if (viewModel.events.isEmpty) {
      return const AppEmptyState(message: 'Aucun evenement pour le moment');
    }

    return ListView.builder(
      itemCount: viewModel.events.length,
      itemBuilder: (context, index) {
        final event = viewModel.events[index];
        // Construisez votre card ici
        return Text(event.title);
      },
    );
  },
)
```

Pas besoin de bouton "rafraichir". Les donnees arrivent toutes seules.

---

## Repartition des taches par membre

### Membre 1 -- Configuration et Profil

**Dossier** : `lib/presentation/profile/`

Le Membre 1 a mis en place toute la configuration du projet. Il lui reste a implementer l'ecran Profil et Parametres.

Taches :
- Implementer `profile_view.dart` : afficher les informations du compte (email, nom, avatar)
- Completer `profile_viewmodel.dart` : la methode `updateProfile()` pour modifier le nom et l'avatar via Supabase
- Ajouter un bouton de deconnexion (la methode `signOut()` est deja codee dans le viewmodel)
- Gerer la navigation vers `/login` apres deconnexion

Fichiers a consulter :
- `core/network/supabase_config.dart` pour acceder aux infos de l'utilisateur connecte
- `core/theme/app_colors.dart` pour les couleurs et ombres a utiliser

---

### Membre 2 -- Authentification

**Dossier** : `lib/presentation/auth/`

Le Membre 2 est responsable de tout ce qui touche a la connexion et l'inscription.

Taches :
- Implementer `login_view.dart` : formulaire avec champs email et mot de passe
- Completer `auth_viewmodel.dart` : décommentez et adaptez les méthodes existantes.
- **Important** : Ne réinventez pas la roue pour l'authentification ! Utilisez simplement les fonctions natives de Supabase : `SupabaseConfig.auth.signInWithPassword()` et `SupabaseConfig.auth.signUp()`. (Le code est déjà expliqué et fournit en commentaire dans le fichier).
- Ajouter la validation des champs (email valide, mot de passe >= 6 caracteres)
- Gerer les messages d'erreur (email deja utilise, mot de passe incorrect, etc.)
- Apres connexion reussie, naviguer vers `/home` avec `context.go('/home')`

Design a respecter :
- Les champs de saisie utilisent le style "underline" (deja configure dans le theme)
- Le bouton principal est en couleur Ocre (`AppColors.primary`)
- Titre en police Newsreader (automatique via le theme)

Fichiers a consulter :
- `core/network/supabase_config.dart` pour `SupabaseConfig.auth`
- `core/utils/router.dart` pour comprendre la navigation

---

### Membre 3 -- Creation d'evenement

**Dossier** : `lib/presentation/creation/`

Le Membre 3 gere le formulaire de creation d'un nouvel evenement.

Taches :
- Implementer `create_event_view.dart` : formulaire complet avec les champs titre, description, date/heure, lieu, nombre max de participants
- Completer `create_event_viewmodel.dart` : la methode `createEvent()` est deja structuree, adaptez-la a vos besoins
- Ajouter un DatePicker et un TimePicker pour le champ date/heure
- Ajouter la validation (titre obligatoire, date dans le futur, etc.)
- Apres creation reussie, naviguer vers `/home`
- Optionnel : ajouter un champ pour uploader une image

Design a respecter :
- Champs minimalistes avec border-bottom
- Le focus sur un champ passe la bordure en Ocre (deja gere par le theme)
- Bouton "Creer" avec l'ombre doree (`AppColors.shadowGolden`)

Fichiers a consulter :
- `data/models/event_model.dart` pour la structure des donnees
- `data/services/event_service.dart` pour l'insertion dans Supabase

---

### Membre 4 -- Feed et Dashboard

**Dossier** : `lib/presentation/home/` et `lib/presentation/detail/` (en collaboration avec Membre 5)

Le Membre 4 est responsable de l'affichage des evenements.

Taches :
- Implementer `home_view.dart` : afficher la liste des evenements en utilisant le `HomeViewModel` (le branchement au Stream Supabase est deja fait dans le viewmodel -- voir la section "Comment le temps reel fonctionne" plus haut)
- Creer des cards pour chaque evenement avec : titre, date, lieu, nombre de participants
- Ajouter un FloatingActionButton qui navigue vers `/create`
- Implementer le tap sur une card pour naviguer vers `/detail/{id}`
- Implementer `event_detail_view.dart` : afficher tous les details d'un evenement (en collaboration avec Membre 5)
- Completer `event_detail_viewmodel.dart` : la methode `loadEvent()` est deja codee

Design a respecter :
- Les cards n'ont pas de bordure visible, elles sont definies par un changement de texture de fond
- Ombre ambiante teintee Indigo sur les cards (`AppColors.shadowIndigo`)
- Utiliser `ImpressionistCard` de `common_widgets.dart` comme base

Fichiers a consulter :
- `presentation/home/viewmodels/home_viewmodel.dart` (le stream est deja branche)
- `presentation/widgets/common_widgets.dart` pour les composants reutilisables

---

### Membre 5 -- Participation

**Dossier** : `lib/presentation/participation/` et `lib/presentation/detail/` (en collaboration avec Membre 4)

Le Membre 5 gere tout ce qui concerne l'inscription des utilisateurs aux evenements.

Taches :
- Implementer `participation_view.dart` : afficher la liste des participants d'un evenement
- Completer `participation_viewmodel.dart` : implementer `loadParticipants()` pour recuperer les participants depuis la table `participants` de Supabase
- Completer `event_detail_viewmodel.dart` : implementer les methodes `joinEvent()` et `leaveEvent()`
- Ajouter un bouton "Participer" / "Se desinscrire" dans l'ecran de detail (coordonnez-vous avec le Membre 4)
- Gerer le cas ou le nombre max de participants est atteint

Design a respecter :
- Liste avec des separateurs fins
- Avatars circulaires pour chaque participant
- Chips de statut (confirme, en attente) avec fond Indigo a 10% d'opacite

Fichiers a consulter :
- `data/services/event_service.dart` et `core/network/base_service.dart` pour comprendre comment creer un service similaire pour la table `participants`
- `core/network/supabase_config.dart` pour `SupabaseConfig.currentUser`

---

## Widgets partages

Le fichier `lib/presentation/widgets/common_widgets.dart` contient des composants que tout le monde peut (et devrait) utiliser :

- `ImpressionistCard` : une carte avec ombre impressionniste floue. Accepte un `child`, un `padding` optionnel, et une liste de `BoxShadow` custom.
- `AppLoadingIndicator` : indicateur de chargement stylise.
- `AppErrorWidget` : message d'erreur avec bouton "Reessayer" optionnel.
- `AppEmptyState` : etat vide avec icone et message.

Si vous avez besoin d'un widget reutilisable, ajoutez-le dans ce fichier plutot que de le dupliquer dans votre dossier.

---

## FAQ

**Je veux ajouter un nouveau package, je fais comment ?**
Discutez-en d'abord avec l'equipe. Si c'est valide, ajoutez-le au `pubspec.yaml` et faites `flutter pub get`. Commitez le changement separement avec un message type `chore: ajout du package xxx`.

**Comment je fais pour tester si le temps reel marche ?**
Lancez l'app sur deux appareils (ou un emulateur + Chrome). Creez un evenement sur l'un, il doit apparaitre sur l'autre sans refresh.

**Les couleurs / polices ne s'affichent pas correctement ?**
Verifiez que vous utilisez `Theme.of(context).textTheme` pour le texte et `AppColors` pour les couleurs. Ne mettez pas de couleurs en dur dans vos widgets.

**J'ai besoin d'une nouvelle route ?**
Ajoutez-la dans `lib/core/utils/router.dart` et la constante correspondante dans `lib/core/constants/app_constants.dart`. Faites-le sur une branche dediee.

**Comment je recupere l'utilisateur connecte ?**
```dart
import 'package:miwakpon/core/network/supabase_config.dart';

final user = SupabaseConfig.currentUser;
final email = user?.email;
final userId = user?.id;
```

**L'app crash au demarrage.**
Verifiez que vous avez bien remplace `VOTRE_SUPABASE_URL` et `VOTRE_SUPABASE_ANON_KEY` dans `supabase_config.dart`.

---

## Stack technique

| Outil | Version | Role |
|-------|---------|------|
| Flutter | >= 3.10.4 | Framework mobile |
| supabase_flutter | 2.12.4 | Backend, Auth, Realtime |
| go_router | 14.8.1 | Navigation declarative |
| provider | 6.1.5 | Gestion d'etat MVVM |
| google_fonts | 6.3.3 | Typographie (Newsreader, Be Vietnam Pro) |
| intl | 0.20.2 | Formatage de dates |

```
Miwakpon
├─ .metadata
├─ analysis_options.yaml
├─ android
│  ├─ app
│  │  ├─ build.gradle.kts
│  │  └─ src
│  │     ├─ debug
│  │     │  └─ AndroidManifest.xml
│  │     ├─ main
│  │     │  ├─ AndroidManifest.xml
│  │     │  ├─ java
│  │     │  │  └─ io
│  │     │  │     └─ flutter
│  │     │  │        └─ plugins
│  │     │  │           └─ GeneratedPluginRegistrant.java
│  │     │  ├─ kotlin
│  │     │  │  └─ com
│  │     │  │     └─ example
│  │     │  │        └─ miwakpon
│  │     │  │           └─ MainActivity.kt
│  │     │  └─ res
│  │     │     ├─ drawable
│  │     │     │  └─ launch_background.xml
│  │     │     ├─ drawable-v21
│  │     │     │  └─ launch_background.xml
│  │     │     ├─ mipmap-hdpi
│  │     │     │  ├─ ic_launcher.png
│  │     │     │  └─ launcher_icon.png
│  │     │     ├─ mipmap-mdpi
│  │     │     │  ├─ ic_launcher.png
│  │     │     │  └─ launcher_icon.png
│  │     │     ├─ mipmap-xhdpi
│  │     │     │  ├─ ic_launcher.png
│  │     │     │  └─ launcher_icon.png
│  │     │     ├─ mipmap-xxhdpi
│  │     │     │  ├─ ic_launcher.png
│  │     │     │  └─ launcher_icon.png
│  │     │     ├─ mipmap-xxxhdpi
│  │     │     │  ├─ ic_launcher.png
│  │     │     │  └─ launcher_icon.png
│  │     │     ├─ values
│  │     │     │  └─ styles.xml
│  │     │     └─ values-night
│  │     │        └─ styles.xml
│  │     └─ profile
│  │        └─ AndroidManifest.xml
│  ├─ build.gradle.kts
│  ├─ gradle
│  │  └─ wrapper
│  │     └─ gradle-wrapper.properties
│  ├─ gradle.properties
│  ├─ local.properties
│  └─ settings.gradle.kts
├─ assets
│  └─ icons
│     └─ icon.jpg
├─ ios
│  ├─ Flutter
│  │  ├─ AppFrameworkInfo.plist
│  │  ├─ Debug.xcconfig
│  │  ├─ ephemeral
│  │  │  ├─ flutter_lldbinit
│  │  │  └─ flutter_lldb_helper.py
│  │  ├─ flutter_export_environment.sh
│  │  ├─ Generated.xcconfig
│  │  └─ Release.xcconfig
│  ├─ Runner
│  │  ├─ AppDelegate.swift
│  │  ├─ Assets.xcassets
│  │  │  ├─ AppIcon.appiconset
│  │  │  │  ├─ Contents.json
│  │  │  │  ├─ Icon-App-1024x1024@1x.png
│  │  │  │  ├─ Icon-App-20x20@1x.png
│  │  │  │  ├─ Icon-App-20x20@2x.png
│  │  │  │  ├─ Icon-App-20x20@3x.png
│  │  │  │  ├─ Icon-App-29x29@1x.png
│  │  │  │  ├─ Icon-App-29x29@2x.png
│  │  │  │  ├─ Icon-App-29x29@3x.png
│  │  │  │  ├─ Icon-App-40x40@1x.png
│  │  │  │  ├─ Icon-App-40x40@2x.png
│  │  │  │  ├─ Icon-App-40x40@3x.png
│  │  │  │  ├─ Icon-App-50x50@1x.png
│  │  │  │  ├─ Icon-App-50x50@2x.png
│  │  │  │  ├─ Icon-App-57x57@1x.png
│  │  │  │  ├─ Icon-App-57x57@2x.png
│  │  │  │  ├─ Icon-App-60x60@2x.png
│  │  │  │  ├─ Icon-App-60x60@3x.png
│  │  │  │  ├─ Icon-App-72x72@1x.png
│  │  │  │  ├─ Icon-App-72x72@2x.png
│  │  │  │  ├─ Icon-App-76x76@1x.png
│  │  │  │  ├─ Icon-App-76x76@2x.png
│  │  │  │  └─ Icon-App-83.5x83.5@2x.png
│  │  │  └─ LaunchImage.imageset
│  │  │     ├─ Contents.json
│  │  │     ├─ LaunchImage.png
│  │  │     ├─ LaunchImage@2x.png
│  │  │     ├─ LaunchImage@3x.png
│  │  │     └─ README.md
│  │  ├─ Base.lproj
│  │  │  ├─ LaunchScreen.storyboard
│  │  │  └─ Main.storyboard
│  │  ├─ GeneratedPluginRegistrant.h
│  │  ├─ GeneratedPluginRegistrant.m
│  │  ├─ Info.plist
│  │  └─ Runner-Bridging-Header.h
│  ├─ Runner.xcodeproj
│  │  ├─ project.pbxproj
│  │  ├─ project.xcworkspace
│  │  │  ├─ contents.xcworkspacedata
│  │  │  └─ xcshareddata
│  │  │     ├─ IDEWorkspaceChecks.plist
│  │  │     └─ WorkspaceSettings.xcsettings
│  │  └─ xcshareddata
│  │     └─ xcschemes
│  │        └─ Runner.xcscheme
│  ├─ Runner.xcworkspace
│  │  ├─ contents.xcworkspacedata
│  │  └─ xcshareddata
│  │     ├─ IDEWorkspaceChecks.plist
│  │     └─ WorkspaceSettings.xcsettings
│  └─ RunnerTests
│     └─ RunnerTests.swift
├─ lib
│  ├─ core
│  │  ├─ constants
│  │  │  └─ app_constants.dart
│  │  ├─ network
│  │  │  ├─ base_service.dart
│  │  │  └─ supabase_config.dart
│  │  ├─ theme
│  │  │  ├─ app_colors.dart
│  │  │  └─ app_theme.dart
│  │  └─ utils
│  │     └─ router.dart
│  ├─ data
│  │  ├─ models
│  │  │  ├─ event_model.dart
│  │  │  └─ user_model.dart
│  │  ├─ repositories_impl
│  │  │  └─ event_repository_impl.dart
│  │  └─ services
│  │     └─ event_service.dart
│  ├─ domain
│  │  ├─ entities
│  │  │  ├─ event_entity.dart
│  │  │  └─ user_entity.dart
│  │  └─ repositories_interfaces
│  │     └─ event_repository.dart
│  ├─ main.dart
│  └─ presentation
│     ├─ auth
│     │  ├─ viewmodels
│     │  │  └─ auth_viewmodel.dart
│     │  └─ views
│     │     └─ login_view.dart
│     ├─ creation
│     │  ├─ viewmodels
│     │  │  └─ create_event_viewmodel.dart
│     │  └─ views
│     │     └─ create_event_view.dart
│     ├─ detail
│     │  ├─ viewmodels
│     │  │  └─ event_detail_viewmodel.dart
│     │  └─ views
│     │     └─ event_detail_view.dart
│     ├─ home
│     │  ├─ viewmodels
│     │  │  └─ home_viewmodel.dart
│     │  └─ views
│     │     └─ home_view.dart
│     ├─ participation
│     │  ├─ viewmodels
│     │  │  └─ participation_viewmodel.dart
│     │  └─ views
│     │     └─ participation_view.dart
│     ├─ profile
│     │  ├─ viewmodels
│     │  │  └─ profile_viewmodel.dart
│     │  └─ views
│     │     └─ profile_view.dart
│     ├─ splash
│     │  └─ views
│     │     └─ splash_view.dart
│     └─ widgets
│        ├─ common_widgets.dart
│        └─ main_layout.dart
├─ pubspec.lock
├─ pubspec.yaml
├─ README.md
├─ SUPABASE_SCHEMA.md
└─ web
   ├─ favicon.png
   ├─ icons
   │  ├─ Icon-192.png
   │  ├─ Icon-512.png
   │  ├─ Icon-maskable-192.png
   │  └─ Icon-maskable-512.png
   ├─ index.html
   └─ manifest.json

```