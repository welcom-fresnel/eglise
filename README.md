# 🌟 Réseau Social Chrétien

Un réseau social moderne et sécurisé pour la communauté chrétienne, développé avec Flutter et Firebase.

## 📋 Table des matières

- [Fonctionnalités](#-fonctionnalités)
- [Stack Technique](#-stack-technique)
- [Architecture](#-architecture)
- [Installation](#-installation)
- [Configuration Firebase](#-configuration-firebase)
- [Structure du Projet](#-structure-du-projet)
- [Développement](#-développement)
- [Sécurité](#-sécurité)
- [Scaling](#-scaling)
- [Contribution](#-contribution)

## ✨ Fonctionnalités

### V1 (MVP)

- ✅ **Authentification sécurisée**
  - Inscription/Connexion avec email et mot de passe
  - Gestion du profil utilisateur (nom, photo, église, bio)
  
- ✅ **Fil d'actualité**
  - Publications texte
  - Publications avec images
  - Versets bibliques avec références
  
- ✅ **Interactions**
  - Likes sur les publications et commentaires
  - Système de commentaires
  
- ✅ **Groupes**
  - Groupes de prière
  - Groupes par église
  - Groupes publics et privés
  
- ✅ **Modération**
  - Signalement de contenu
  - Blocage d'utilisateurs
  - Rôles (utilisateur, modérateur, administrateur)
  
- ✅ **Notifications** (à implémenter)
  - Nouveaux commentaires
  - Interactions (likes, etc.)

## 🛠 Stack Technique

- **Frontend** : Flutter 3.10+
- **Backend** : Firebase + Cloudinary
  - Authentication (Firebase)
  - Cloud Firestore (Firebase)
  - Cloudinary (Storage d'images - optimisé avec CDN)
  - Cloud Functions (à venir)
  - Cloud Messaging (à venir)
- **State Management** : Riverpod
- **Routing** : go_router
- **Architecture** : Clean Architecture
- **Dependency Injection** : GetIt

## 🏗 Architecture

Le projet suit une **Clean Architecture** avec 3 couches principales :

```
┌─────────────────────────────────────┐
│      Presentation (UI)              │
│  - Screens, Widgets, Providers     │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Domain (Business Logic)        │
│  - Entities, Use Cases, Repos      │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Data (Implementation)          │
│  - Firebase, Models, Repos Impl    │
└─────────────────────────────────────┘
```

Voir [ARCHITECTURE.md](ARCHITECTURE.md) pour plus de détails.

## 🚀 Installation

### Prérequis

- Flutter SDK 3.10.4 ou supérieur
- Dart SDK
- Android Studio / Xcode (pour le développement mobile)
- Compte Firebase

### Étapes

1. **Cloner le projet**
   ```bash
   git clone <repository-url>
   cd eglise
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Générer les fichiers de code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configurer Firebase**
   - Créer un projet Firebase
   - Ajouter les fichiers de configuration :
     - `android/app/google-services.json` (Android)
     - `ios/Runner/GoogleService-Info.plist` (iOS)
   - Voir [Configuration Firebase](#-configuration-firebase)

5. **Déployer les règles de sécurité**
   ```bash
   firebase deploy --only firestore:rules
   firebase deploy --only storage:rules
   ```

6. **Lancer l'application**
   ```bash
   flutter run
   ```

## 🔥 Configuration Firebase

### 1. Créer un projet Firebase

1. Aller sur [Firebase Console](https://console.firebase.google.com/)
2. Créer un nouveau projet
3. Activer les services :
   - Authentication (Email/Password)
   - Cloud Firestore
   - Firebase Storage
   - Cloud Functions (optionnel pour l'instant)

### 2. Configuration Android

1. Dans Firebase Console, ajouter une app Android
2. Télécharger `google-services.json`
3. Placer le fichier dans `android/app/`
4. Vérifier que `android/build.gradle` contient :
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
5. Vérifier que `android/app/build.gradle` contient :
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### 3. Configuration iOS

1. Dans Firebase Console, ajouter une app iOS
2. Télécharger `GoogleService-Info.plist`
3. Placer le fichier dans `ios/Runner/`
4. Ouvrir `ios/Runner.xcworkspace` dans Xcode
5. Vérifier que le fichier est ajouté au projet

### 4. Déployer les règles de sécurité

```bash
# Installer Firebase CLI si nécessaire
npm install -g firebase-tools

# Se connecter
firebase login

# Initialiser (si pas déjà fait)
firebase init

# Déployer les règles
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

## 📁 Structure du Projet

```
lib/
├── core/                    # Code partagé
│   ├── constants/          # Constantes
│   ├── errors/             # Gestion des erreurs
│   ├── utils/              # Utilitaires
│   └── di/                 # Dependency Injection
│
├── domain/                 # Couche métier
│   ├── entities/           # Entités
│   ├── repositories/       # Interfaces
│   └── usecases/           # Cas d'usage
│
├── data/                   # Couche données
│   ├── models/             # DTOs
│   ├── datasources/        # Sources de données
│   └── repositories/       # Implémentations
│
└── presentation/           # Couche présentation
    ├── screens/            # Écrans
    ├── widgets/            # Widgets
    ├── providers/          # Providers Riverpod
    ├── theme/              # Thème
    └── routes/             # Routage
```

## 💻 Développement

### Commandes utiles

```bash
# Générer les fichiers de code
flutter pub run build_runner watch

# Lancer les tests
flutter test

# Analyser le code
flutter analyze

# Formater le code
dart format lib/

# Build pour Android
flutter build apk

# Build pour iOS
flutter build ios
```

### Workflow de développement

1. Créer une branche pour la fonctionnalité
2. Développer en suivant l'architecture Clean
3. Ajouter des tests
4. Vérifier avec `flutter analyze`
5. Créer une Pull Request

### Bonnes pratiques

- Suivre la Clean Architecture
- Valider les données dans les use cases
- Gérer les erreurs avec `Result<T>`
- Documenter le code complexe
- Utiliser des types forts (pas de `dynamic`)
- Tester les fonctionnalités critiques

## 🔒 Sécurité

### Règles Firestore

Les règles de sécurité sont définies dans `firestore.rules` :

- Vérification de l'authentification
- Vérification des permissions (owner, moderator, admin)
- Protection contre les utilisateurs bloqués
- Validation des données

### Règles Storage

Les règles de stockage sont définies dans `storage.rules` :

- Limitation de la taille (10 MB)
- Vérification du type (images uniquement)
- Protection par utilisateur

### Bonnes pratiques de sécurité

- Ne jamais exposer les clés API dans le code
- Utiliser les règles Firestore pour la sécurité
- Valider toutes les entrées utilisateur
- Utiliser HTTPS pour toutes les communications
- Implémenter la modération de contenu

## 📈 Scaling

Voir [SCALING.md](SCALING.md) pour les stratégies de montée en charge.

### Optimisations actuelles

- Pagination pour les listes
- Index Firestore
- Mise en cache avec Riverpod

### Optimisations futures

- Algolia/Elasticsearch pour la recherche
- Cloud Functions pour les opérations lourdes
- CDN pour les images
- Cache local (Hive)
- Mode offline-first

## 🤝 Contribution

Les contributions sont les bienvenues ! Merci de :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📝 License

Ce projet est sous licence MIT.

## 👥 Équipe

- Lead Developer: [Votre nom]

## 📞 Support

Pour toute question ou problème, ouvrez une issue sur GitHub.

---

**Fait avec ❤️ pour la communauté chrétienne**
