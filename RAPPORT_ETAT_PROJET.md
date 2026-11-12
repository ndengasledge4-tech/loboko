# LOBOKO — Rapport d'État du Projet

**Date de mise à jour** : Avril 2025  
**Projet** : Application mobile LOBOKO (Services urbains à Brazzaville, République du Congo)  
**Technologie** : Flutter / Dart  
**État de l'analyse statique** : `flutter analyze --no-pub` -> **0 erreur (1 info mineure de style)**  
**État des tests automatisés** : **43 tests exécutés avec succès (Passed)**

---

## 1. Vue d'ensemble de l'Architecture du Projet

Le projet LOBOKO respecte une architecture modulaire et propre :

```text
lib/
├── main.dart                          # Point d'entrée de l'application
├── app/
│   ├── app.dart                       # Configuration globale MaterialApp & ThemeData Material 3
│   ├── routes/
│   │   ├── route_names.dart           # Constantes centralisées des noms de routes
│   │   ├── app_routes.dart            # Registre des routes valides
│   │   └── routes_generator.dart      # Générateur dynamique de routes avec typage des arguments
│   └── theme/
│       └── app_theme.dart             # Thème global (GoogleFonts.inter, palette LOBOKO)
├── features/
│   ├── auth/                          # Connexion, Inscription Multi-Étapes Client/Prestataire, Mot de passe oublié
│   ├── bookings/                      # Réservations Client (Formulaire, Confirmation, Liste)
│   ├── explore/                       # Explorer les services (Grille 11 catégories, services populaires)
│   ├── favorites/                     # Favoris Client
│   ├── home/                          # Accueil Client principal (Recherche, Filtres par quartier, Réservations)
│   ├── messaging/                     # Messagerie Client (Liste conversations, Chat)
│   ├── notifications/                 # Centre de notifications Client
│   ├── onboarding/                    # Carrousel d'Onboarding 3 slides
│   ├── profile/                       # Profil & Édition du profil Client
│   ├── profile_selection/             # Choix du profil (Client / Prestataire)
│   ├── provider/                      # Espace Prestataire (Workspace, Dashboard, Demandes, Missions, Catalogue services, Profil, Messagerie, Notifications)
│   ├── providers/                     # Liste & Fiche détaillée des Prestataires
│   └── splash/                        # Splash Screen d'ouverture
├── mock/
│   └── mock_data.dart                 # Stockage centralisé en mémoire des données de démonstration (Brazzaville)
└── shared/                            # Composants réutilisables & Identité visuelle
    ├── constants/                     # Espacements, rayons, dimensions, UserProfile enum
    ├── helpers/                       # AppValidators (+242, e-mail, mdp) & AppFormatters (prix FCFA, dates)
    ├── theme/                         # AppColors & AppTextStyles
    └── widgets/
        ├── buttons/                   # Primary, Secondary, Text, Icon Buttons
        ├── cards/                     # Category, Provider, Service, Reservation, Stat Cards
        ├── dialogs/                   # Confirmation, Error, Info, Success Dialogs
        ├── feedback/                  # Empty State, Error State, Message Banner, Status Badge
        ├── inputs/                    # Text, Password, Phone, Search, Multiline, AppOtpField
        ├── loading/                   # Loading Indicator
        └── navigation/                # BackButton, BottomNav, FilterChip, Header, SearchBar, TabSelector, Sort
```

---

## 2. Synthèse de l'Avancement des Modules

### A. Design System & Composants Partagés (`lib/shared/`)
- **Statut** : **100% Finalisé & Audité**
- **Charte graphique** : Vert forêt (`#176B45`), Vert naturel (`#4CAF72`), Vert clair (`#E8F5ED`), Doré (`#F2C94C`), Fond (`#F5F7F6`), Texte (`#17221C`, `#66736C`). Typographie **Inter**.
- **Composants** : 38 composants réutilisables isolés dans `lib/shared/widgets/` (aucun widget partagé dans les dossiers `features/`).
- **Helpers** : `AppValidators` (prise en charge téléphone congolais `+242` et e-mail) et `AppFormatters` (formatage monétaire FCFA).

### B. Inscription & Authentification (`lib/features/auth/` & `profile_selection/`)
- **Splash Screen (`/`)** : Écran de démarrage avec badge, tagline et redirection automatique vers l'onboarding.
- **Onboarding (`/onboarding`)** : Carrousel 3 slides interactives (*Trouver*, *Réserver*, *Développer*).
- **Choix du Profil (`/profile-selection`)** : Cartes sélectionnables pour *Client* (`UserProfile.client`) et *Prestataire* (`UserProfile.provider`).
- **Connexion (`/login`)** : Formulaire mixte téléphone/e-mail avec détection intelligente et badge de profil actif.
- **Inscription Client (`/register`)** : Formulaire multi-étapes (Stepper 4 étapes : *Infos personnelles*, *Coordonnées*, *Sécurité*, *Récapitulatif & CGU*).
- **Inscription Prestataire (`/register`)** : Formulaire multi-étapes (Stepper 5 étapes : *Infos personnelles*, *Coordonnées*, *Infos professionnelles/Métier*, *Conditions d'intervention*, *Sécurité & Récapitulatif*).
- **Mot de passe oublié (`/forgot-password`)** : Parcours 4 étapes (*Identification*, *Code OTP 6 chiffres*, *Nouveau mot de passe*, *Confirmation*).

### C. Espace Client (`lib/features/`)
- **Accueil Client (`/client-home`)** : Salutation dynamique (*"Bonjour, Grace 👋"*), barre de recherche, filtre par quartiers de Brazzaville (Bacongo, Poto-Poto, Moungali, Talangaï, etc.), défilement des catégories, prestataires populaires et réservations.
- **Explorer les services (`/client-explore`)** : Grille responsive des 11 catégories de services (Plomberie, Électricité, Menuiserie, Maçonnerie, Peinture, Mécanique, Beauté & coiffure, Nettoyage, Jardinage, Réparation & entretien, Autres) et cartes de services populaires avec tarifs en FCFA.
- **Liste des prestataires (`/client-providers`)** : Recherche locale, filtres rapides par chips (*Tous*, *Mieux notés*, *Moins chers*, *Plus expérimentés*), bascule de favoris et cartes professionnelles.
- **Fiche Prestataire (`/client-provider-detail`)** : Informations complètes, spécialités, zone d'intervention, tarifs et bouton d'action vers la réservation.
- **Prise de réservation (`/client-booking`)** : Choix de la prestation, de la date et du créneau horaire avec confirmation.
- **Messagerie Client (`/client-messages` & `/client-chat`)** : Liste des conversations et fil de discussion bidirectionnel synchronisé avec le prestataire.
- **Favoris (`/client-favorites`)** : Gestion des prestataires sauvegardés.
- **Centre de notifications (`/client-notifications`)** : Suivi des alertes de réservation et de messages.
- **Profil Client (`/client-profile` & `/client-profile-edit`)** : Consultation et modification des informations de session.

### D. Espace Prestataire (`lib/features/provider/`)
- **Tableau de bord (`/provider-dashboard`)** : Cartes statistiques réactives (Demandes en attente, Missions en cours, Revenus, Note globale), aperçu des dernières activités et raccourcis d'action.
- **Gestion des demandes (`/provider-requests` & `/provider-request-detail`)** : Liste filtrable des demandes reçues, détails du client/lieu/date et actions d'acceptation ou de refus.
- **Suivi des missions (`/provider-missions` & `/provider-mission-detail`)** : Suivi du cycle de vie de l'intervention (*En cours* -> *Terminée* -> *Historique*).
- **Catalogue "Mes services" (`/provider-services` & `/provider-service-form`)** : Consultation, ajout, édition, désactivation et suppression des prestations proposées.
- **Profil Prestataire (`/provider-profile` & `/provider-profile-edit`)** : Profil professionnel complet, mode d'intervention (*À domicile*, *En atelier*, *Les deux*), zone géographique et édition des informations.
- **Messagerie Prestataire (`/provider-messages` & `/provider-chat`)** : Discussion partagée en temps réel avec la même conversation Client dans `MockData`.
- **Barre de navigation inférieure à 5 onglets** : Navigation persistante entre *Accueil*, *Demandes*, *Missions*, *Messages* et *Profil*.

---

## 3. Flux de Navigation et Routage Centralisé

```text
[ Démarrage ] ──► Splash (/) ──► Onboarding (/onboarding) ──► Choix Profil (/profile-selection)
                                                                       │
                                                                       ▼
                                                             Connexion (/login)
                                                                │          │
                                                                ▼          ▼
                                                         Inscription     Réinitialisation MDP
                                                          (/register)     (/forgot-password)
                                                                │
                                    ┌───────────────────────────┴───────────────────────────┐
                                    ▼                                                       ▼
                            ESPACE CLIENT                                           ESPACE PRESTATAIRE
               ├── Accueil (/client-home)                             ├── Workspace / Dashboard (/provider-dashboard)
               ├── Explorer (/client-explore)                         ├── Demandes (/provider-requests)
               ├── Prestataires (/client-providers)                   ├── Missions (/provider-missions)
               ├── Fiche Prestataire (/client-provider-detail)        ├── Catalogue Services (/provider-services)
               ├── Réservation (/client-booking)                      ├── Messagerie (/provider-messages & /provider-chat)
               ├── Messagerie (/client-messages & /client-chat)        └── Profil (/provider-profile & /provider-profile-edit)
               ├── Notifications (/client-notifications)
               └── Profil (/client-profile)
```

---

## 4. Analyse Qualité et Couverture des Tests

1. **Analyse Statique (`flutter analyze --no-pub`)** :
   - **0 erreur, 0 avertissement bloquant**.
   - Code propre, typé et compatible avec Flutter 3.27+.

2. **Tests Automatisés (`flutter test --no-pub`)** :
   - **43 tests unitaires et de widgets exécutés avec succès** (100% Passed).
   - Couverture des parcours Client (Onboarding, Connexion, Recherche, Filtrage, Réservation, Messagerie, Profil) et Prestataire (Dashboard, Demandes, Missions, Catalogue de services, Profil).
   - Validation du comportement responsive sur petits écrans (320×568 et 390×844).

---

## 5. Prochaines Étapes du Projet

1. **Étape suivante** : Conception et développement de l'**Espace Administrateur** (Supervision globale des utilisateurs, validation des dossiers prestataires, gestion des catégories et litiges).
2. **Préparation Backend** : Abstraction de la couche `MockData` pour l'intégration ultérieure d'un backend REST/GraphQL ou Firebase Authentication & Firestore.
