# 🚀 Guide de Configuration Initiale

Guide pas à pas pour configurer le projet depuis zéro.

## 📋 Prérequis

### Outils nécessaires

1. **Flutter SDK** (3.10.4+)
   ```bash
   flutter --version
   ```

2. **Dart SDK** (inclus avec Flutter)

3. **Android Studio** ou **VS Code** avec extensions Flutter

4. **Git**

5. **Compte Firebase** (gratuit pour commencer)

6. **Node.js** (pour Firebase CLI)
   ```bash
   node --version
   ```

## 🔧 Installation étape par étape

### 1. Cloner et installer les dépendances

```bash
# Cloner le projet
git clone <repository-url>
cd eglise

# Installer les dépendances Flutter
flutter pub get

# Générer les fichiers de code (json_serializable, freezed, etc.)
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Configuration Firebase

#### A. Créer un projet Firebase

1. Aller sur [Firebase Console](https://console.firebase.google.com/)
2. Cliquer sur "Ajouter un projet"
3. Nommer le projet (ex: "reseau-social-chretien")
4. Activer Google Analytics (recommandé)
5. Créer le projet

#### B. Activer les services Firebase

Dans la console Firebase, activer :

1. **Authentication**
   - Onglet "Authentication" → "Get started"
   - Activer "Email/Password" dans "Sign-in method"

2. **Cloud Firestore**
   - Onglet "Firestore Database" → "Create database"
   - Choisir "Start in test mode" (on déploiera les règles après)
   - Choisir une région (ex: europe-west)

3. **Cloudinary** (Storage d'images)
   - Voir [CLOUDINARY_SETUP.md](CLOUDINARY_SETUP.md) pour la configuration complète
   - Créer un compte sur [cloudinary.com](https://cloudinary.com)
   - Récupérer les credentials (Cloud Name, API Key, API Secret)
   - Configurer un Upload Preset (recommandé)

#### C. Configuration Android

1. Dans Firebase Console :
   - Aller dans "Project Settings" (⚙️)
   - Onglet "Your apps"
   - Cliquer sur l'icône Android
   - Package name : `com.example.eglise` (ou votre package)
   - Télécharger `google-services.json`

2. Placer le fichier :
   ```bash
   # Copier google-services.json dans android/app/
   cp ~/Downloads/google-services.json android/app/
   ```

3. Vérifier `android/build.gradle` :
   ```gradle
   buildscript {
       dependencies {
           classpath 'com.google.gms:google-services:4.4.0'
       }
   }
   ```

4. Vérifier `android/app/build.gradle` :
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### D. Configuration iOS

1. Dans Firebase Console :
   - Onglet "Your apps"
   - Cliquer sur l'icône iOS
   - Bundle ID : `com.example.eglise` (ou votre bundle)
   - Télécharger `GoogleService-Info.plist`

2. Placer le fichier :
   ```bash
   # Copier GoogleService-Info.plist dans ios/Runner/
   cp ~/Downloads/GoogleService-Info.plist ios/Runner/
   ```

3. Ouvrir Xcode :
   ```bash
   open ios/Runner.xcworkspace
   ```
   - Glisser `GoogleService-Info.plist` dans le projet
   - Cocher "Copy items if needed"

### 3. Déployer les règles de sécurité

#### A. Installer Firebase CLI

```bash
npm install -g firebase-tools
```

#### B. Se connecter à Firebase

```bash
firebase login
```

#### C. Initialiser Firebase (si pas déjà fait)

```bash
firebase init
```

Choisir :
- Firestore : Yes
- Storage : Yes
- Functions : No (pour l'instant)
- Hosting : No (pour l'instant)

#### D. Déployer les règles

```bash
# Déployer les règles Firestore
firebase deploy --only firestore:rules

# Déployer les règles Storage
firebase deploy --only storage:rules
```

### 4. Créer les index Firestore

Dans Firebase Console :
1. Aller dans "Firestore Database"
2. Onglet "Indexes"
3. Cliquer sur "Create Index"
4. Créer les index suivants :

**Index 1 : Feed posts**
- Collection: `posts`
- Fields:
  - `isModerated` (Ascending)
  - `createdAt` (Descending)
- Query scope: Collection

**Index 2 : User posts**
- Collection: `posts`
- Fields:
  - `authorId` (Ascending)
  - `createdAt` (Descending)
- Query scope: Collection

**Index 3 : Group posts**
- Collection: `posts`
- Fields:
  - `groupId` (Ascending)
  - `createdAt` (Descending)
- Query scope: Collection

### 5. Vérifier la configuration

```bash
# Vérifier que tout compile
flutter analyze

# Lancer l'application
flutter run
```

## 🧪 Tester l'application

### 1. Tester l'authentification

1. Lancer l'app
2. Créer un compte avec email/password
3. Vérifier dans Firebase Console → Authentication que l'utilisateur apparaît
4. Vérifier dans Firestore → `users` qu'un document a été créé

### 2. Tester Firestore

1. Créer un post (quand implémenté)
2. Vérifier dans Firestore → `posts` que le document existe

### 3. Tester Cloudinary

1. Configurer Cloudinary (voir [CLOUDINARY_SETUP.md](CLOUDINARY_SETUP.md))
2. Tester un upload d'image (quand implémenté)
3. Vérifier dans Cloudinary Dashboard → Media Library que l'image apparaît

## 🐛 Dépannage

### Erreur : "MissingPluginException"

```bash
# Nettoyer et reconstruire
flutter clean
flutter pub get
flutter run
```

### Erreur : "Firebase not initialized"

Vérifier que :
- `google-services.json` est dans `android/app/`
- `GoogleService-Info.plist` est dans `ios/Runner/`
- Firebase est initialisé dans `main.dart`

### Erreur : "Permission denied" dans Firestore

Vérifier que :
- Les règles Firestore sont déployées
- L'utilisateur est authentifié
- Les règles correspondent à votre structure

### Erreur : Build runner

```bash
# Nettoyer et régénérer
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📱 Configuration pour différents environnements

### Développement

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const bool isProduction = false;
  static const String firebaseProjectId = 'your-dev-project';
}
```

### Production

1. Créer un projet Firebase séparé pour la production
2. Utiliser des fichiers de configuration différents
3. Configurer les variables d'environnement

## ✅ Checklist de configuration

- [ ] Flutter SDK installé
- [ ] Dépendances installées (`flutter pub get`)
- [ ] Fichiers générés (`build_runner`)
- [ ] Projet Firebase créé
- [ ] Authentication activé
- [ ] Firestore créé
- [ ] Storage créé
- [ ] `google-services.json` configuré (Android)
- [ ] `GoogleService-Info.plist` configuré (iOS)
- [ ] Règles Firestore déployées
- [ ] Cloudinary configuré (voir CLOUDINARY_SETUP.md)
- [ ] Index Firestore créés
- [ ] Application compile sans erreur
- [ ] Test d'authentification réussi

## 🎯 Prochaines étapes

Une fois la configuration terminée :

1. Lire [ARCHITECTURE.md](ARCHITECTURE.md) pour comprendre la structure
2. Lire [SCALING.md](SCALING.md) pour les optimisations futures
3. Commencer le développement des fonctionnalités

## 📞 Support

Si vous rencontrez des problèmes :

1. Vérifier les logs : `flutter run -v`
2. Vérifier Firebase Console pour les erreurs
3. Consulter la [documentation Firebase](https://firebase.google.com/docs)
4. Ouvrir une issue sur GitHub

---

**Bon développement ! 🚀**

