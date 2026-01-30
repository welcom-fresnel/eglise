# Architecture du Projet

## Vue d'ensemble

Ce projet utilise une **Clean Architecture** avec Flutter et Firebase, conçue pour être scalable, maintenable et testable.

## Structure des couches

```
lib/
├── core/                    # Code partagé (constantes, erreurs, utils)
│   ├── constants/          # Constantes de l'application
│   ├── errors/             # Gestion des erreurs (Failures)
│   ├── utils/              # Utilitaires (logger, result)
│   └── di/                 # Dependency Injection
│
├── domain/                 # Couche métier (indépendante)
│   ├── entities/           # Entités métier (User, Post, Comment, Group)
│   ├── repositories/       # Interfaces des repositories (abstractions)
│   └── usecases/           # Cas d'usage métier
│
├── data/                   # Couche données (implémentations)
│   ├── models/             # Modèles de données (DTOs pour Firebase)
│   ├── datasources/        # Sources de données (Firebase Auth, Firestore, Storage)
│   └── repositories/       # Implémentations des repositories
│
└── presentation/           # Couche présentation (UI)
    ├── screens/            # Écrans de l'application
    ├── widgets/            # Widgets réutilisables
    ├── providers/          # Providers Riverpod (state management)
    ├── theme/              # Thème de l'application
    └── routes/             # Configuration du routage
```

## Flux de données

```
UI (Presentation)
    ↓
Use Cases (Domain)
    ↓
Repositories (Domain - Interface)
    ↓
Repositories Impl (Data - Implémentation)
    ↓
Data Sources (Data - Firebase)
    ↓
Firebase (Backend)
```

## Principes de conception

### 1. Séparation des responsabilités
- **Domain** : Logique métier pure, indépendante de Firebase
- **Data** : Implémentations techniques (Firebase, API, etc.)
- **Presentation** : UI et state management

### 2. Inversion de dépendances
- La couche `domain` ne dépend pas de `data`
- Les repositories sont des interfaces dans `domain`
- Les implémentations sont dans `data`

### 3. Single Responsibility
- Chaque classe a une seule responsabilité
- Les use cases encapsulent une action métier spécifique

### 4. Dependency Injection
- Utilisation de GetIt pour l'injection de dépendances
- Facilite les tests et la maintenance

## Gestion des erreurs

Utilisation d'un système de `Result<T>` avec `Failure` :

```dart
Result<User> result = await signInUseCase(email, password);
result.when(
  success: (user) => // Gérer le succès
  error: (failure) => // Gérer l'erreur
);
```

Types de `Failure` :
- `ServerFailure` : Erreurs serveur/Firebase
- `AuthFailure` : Erreurs d'authentification
- `ValidationFailure` : Erreurs de validation
- `PermissionFailure` : Erreurs de permissions
- `ModerationFailure` : Contenu modéré

## State Management

Utilisation de **Riverpod** pour la gestion d'état :

- **Providers** : Fournissent les dépendances et l'état
- **StateNotifier** : Pour l'état complexe avec logique
- **StreamProvider** : Pour les streams (auth state, etc.)

## Sécurité

### Firestore Rules
- Vérification de l'authentification
- Vérification des permissions (owner, moderator, admin)
- Protection contre les utilisateurs bloqués
- Validation des données

### Storage Rules
- Limitation de la taille des fichiers (10 MB)
- Vérification du type de fichier (images uniquement)
- Protection par utilisateur

## Scalabilité

### Optimisations actuelles
- Pagination pour les listes (posts, comments)
- Index Firestore pour les requêtes fréquentes
- Mise en cache avec Riverpod

### Optimisations futures
- **Algolia/Elasticsearch** : Pour la recherche avancée
- **Cloud Functions** : Pour les opérations lourdes
- **CDN** : Pour les images (Cloudinary)
- **Caching** : Hive/SharedPreferences pour le cache local
- **Offline-first** : Synchronisation locale avec Firestore

## Tests

Structure recommandée :

```
test/
├── domain/
│   ├── entities/           # Tests des entités
│   └── usecases/           # Tests des use cases
├── data/
│   ├── datasources/        # Tests des data sources
│   └── repositories/       # Tests des repositories
└── presentation/
    └── providers/          # Tests des providers
```

## Bonnes pratiques

1. **Validation** : Toujours valider dans les use cases
2. **Logging** : Utiliser `AppLogger` pour tracer les opérations
3. **Documentation** : Commenter le code complexe
4. **Types** : Utiliser des types forts (pas de `dynamic`)
5. **Null safety** : Gérer les valeurs nulles explicitement
6. **Error handling** : Toujours gérer les erreurs avec `Result`

## Prochaines étapes

1. Ajouter les tests unitaires
2. Implémenter les Cloud Functions pour les notifications
3. Ajouter la recherche avancée (Algolia)
4. Optimiser les performances (lazy loading, caching)
5. Ajouter les analytics (Firebase Analytics)
6. Implémenter les tests d'intégration

