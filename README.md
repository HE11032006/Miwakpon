# Miwakpon

> **Lien de téléchargement** : Retrouvez l'APK de démonstration dans la section [Releases](https://github.com/votre-utilisateur/votre-depot/releases) de ce dépôt.

Miwakpon est une application mobile moderne de gestion d'événements, conçue pour offrir une expérience fluide et interactive. Elle permet aux utilisateurs de créer, découvrir et rejoindre des événements en temps réel.

## Fonctionnalités

- Authentification Sécurisée : Connexion et inscription via Supabase Auth.
- Tableau de Bord Dynamique : Visualisez les événements à la une et votre propre historique.
- Création d'Événements : Interface intuitive pour poster vos événements avec photos, dates et lieux.
- Temps Réel : Les listes d'événements et les participants se mettent à jour instantanément sur tous les appareils.
- Gestion des Profils : Personnalisez votre profil avec une photo, un pseudo et vos informations de contact.
- Suppression et Modification : Gardez le contrôle total sur les événements que vous organisez.

## Installation

1. Cloner le projet
   ```bash
   git clone <url-du-depot>
   cd miwakpon
   ```

2. Installer les dépendances
   ```bash
   flutter pub get
   ```

3. Lancer l'application
   ```bash
   flutter run
   ```

Note : Le fichier de configuration (.env) est déjà inclus dans le projet pour faciliter l'évaluation.

## Architecture

Le projet suit une architecture de type MVVM (Model-View-ViewModel) pour assurer une séparation claire entre la logique métier et l'interface utilisateur :

- lib/core : Constantes, thèmes, routeur et configurations réseau.
- lib/data : Modèles de données et services (API/Supabase).
- lib/presentation : Vues (UI) et ViewModels (logique d'état).

## Générer l'APK

Pour générer une version de production :
```bash
flutter build apk --split-per-abi
```

---
Développé pour une expérience événementielle unique au Bénin.
