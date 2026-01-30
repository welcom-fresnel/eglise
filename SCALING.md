# 📈 Guide de Scaling - Réseau Social Chrétien

Ce document décrit les stratégies et optimisations pour préparer l'application à supporter des milliers voire millions d'utilisateurs.

## 🎯 Objectifs de Scaling

- **Performance** : Temps de réponse < 2 secondes
- **Disponibilité** : 99.9% uptime
- **Coûts** : Optimiser les coûts Firebase
- **Expérience utilisateur** : Fluide même avec beaucoup d'utilisateurs

## 🔥 Optimisations Firebase

### 1. Firestore

#### Index composites
Créer des index pour les requêtes fréquentes :

```javascript
// Exemple : Index pour le feed avec filtres
{
  "collectionGroup": "posts",
  "queryScope": "COLLECTION",
  "fields": [
    { "fieldPath": "isModerated", "order": "ASCENDING" },
    { "fieldPath": "createdAt", "order": "DESCENDING" }
  ]
}
```

#### Pagination efficace
- Utiliser `startAfterDocument` au lieu de `startAt`
- Limiter à 20-50 documents par page
- Implémenter la pagination infinie côté client

#### Structure des données
- Éviter les requêtes avec `where` multiples
- Utiliser des sous-collections pour les commentaires
- Normaliser les données fréquemment lues

#### Exemple d'optimisation
```dart
// ❌ MAUVAIS : Requête lente
final posts = await firestore
    .collection('posts')
    .where('authorId', isEqualTo: userId)
    .where('isModerated', isEqualTo: false)
    .where('createdAt', isGreaterThan: date)
    .get();

// ✅ BON : Utiliser un index composite
final posts = await firestore
    .collection('posts')
    .where('authorId', isEqualTo: userId)
    .where('isModerated', isEqualTo: false)
    .orderBy('createdAt', descending: true)
    .limit(20)
    .get();
```

### 2. Firebase Storage

#### Compression d'images
```dart
// Utiliser image_picker avec compression
final image = await ImagePicker().pickImage(
  source: ImageSource.gallery,
  imageQuality: 85, // Compression
  maxWidth: 1920,
  maxHeight: 1920,
);
```

#### CDN pour les images
- Utiliser Cloudinary ou Imgix pour le CDN
- Générer des thumbnails automatiquement
- Lazy loading des images

#### Optimisation des uploads
- Upload en arrière-plan
- Compression avant upload
- Limiter la taille (10 MB max)

### 3. Cloud Functions

#### Fonctions critiques à implémenter

**1. Notifications push**
```javascript
exports.onNewComment = functions.firestore
  .document('comments/{commentId}')
  .onCreate(async (snap, context) => {
    // Envoyer notification au propriétaire du post
    // Utiliser FCM
  });
```

**2. Modération automatique**
```javascript
exports.moderateContent = functions.firestore
  .document('posts/{postId}')
  .onCreate(async (snap, context) => {
    // Analyser le contenu avec ML
    // Marquer comme modéré si nécessaire
  });
```

**3. Statistiques agrégées**
```javascript
exports.updatePostStats = functions.firestore
  .document('posts/{postId}')
  .onUpdate(async (change, context) => {
    // Mettre à jour les statistiques
    // Éviter les lectures multiples
  });
```

**4. Nettoyage automatique**
```javascript
exports.cleanupOldData = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    // Supprimer les données anciennes
    // Archiver les posts non modérés après X jours
  });
```

## 🗄️ Architecture de données

### Structure optimisée

#### Posts avec sous-collections
```
posts/{postId}
  ├── metadata (données principales)
  └── comments/{commentId} (sous-collection)
      └── replies/{replyId} (sous-collection)
```

**Avantages** :
- Meilleure performance pour les commentaires
- Moins de lectures pour charger un post
- Scalabilité améliorée

#### Cache des données fréquentes
```dart
// Utiliser Riverpod avec cache
final userProvider = FutureProvider.family<User, String>((ref, userId) async {
  // Cache automatique avec Riverpod
  return await userRepository.getUserById(userId);
});
```

### Index Firestore recommandés

```javascript
// Index pour le feed global
{
  "collectionGroup": "posts",
  "fields": [
    { "fieldPath": "isModerated", "order": "ASCENDING" },
    { "fieldPath": "createdAt", "order": "DESCENDING" }
  ]
}

// Index pour les posts d'un utilisateur
{
  "collectionGroup": "posts",
  "fields": [
    { "fieldPath": "authorId", "order": "ASCENDING" },
    { "fieldPath": "createdAt", "order": "DESCENDING" }
  ]
}

// Index pour les posts d'un groupe
{
  "collectionGroup": "posts",
  "fields": [
    { "fieldPath": "groupId", "order": "ASCENDING" },
    { "fieldPath": "createdAt", "order": "DESCENDING" }
  ]
}
```

## 🔍 Recherche avancée

### Phase 1 : Recherche simple (actuelle)
- Recherche par nom dans Firestore
- Limité à 50 résultats
- Pas de recherche full-text

### Phase 2 : Algolia (recommandé)

#### Pourquoi Algolia ?
- Recherche full-text performante
- Typo-tolerance
- Facettes et filtres avancés
- Analytics intégrés

#### Implémentation
```dart
// Synchroniser Firestore avec Algolia
// Via Cloud Function
exports.syncToAlgolia = functions.firestore
  .document('posts/{postId}')
  .onWrite(async (change, context) => {
    const algolia = require('algoliasearch');
    const client = algolia(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
    const index = client.initIndex('posts');
    
    if (!change.after.exists) {
      // Supprimer
      await index.deleteObject(context.params.postId);
    } else {
      // Ajouter/Mettre à jour
      await index.saveObject({
        objectID: context.params.postId,
        ...change.after.data(),
      });
    }
  });
```

### Phase 3 : Elasticsearch (pour très grande échelle)
- Plus de contrôle
- Meilleur pour les données complexes
- Nécessite plus d'infrastructure

## 📱 Optimisations Client

### 1. Lazy Loading

```dart
// Charger les images à la demande
CachedNetworkImage(
  imageUrl: post.imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  fadeInDuration: Duration(milliseconds: 300),
)
```

### 2. Pagination infinie

```dart
class FeedNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  List<Post> _posts = [];
  String? _lastPostId;
  bool _hasMore = true;

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    
    state = AsyncValue.loading();
    final result = await _postRepository.getFeedPosts(
      lastPostId: _lastPostId,
      limit: 20,
    );
    
    result.when(
      success: (newPosts) {
        _posts.addAll(newPosts);
        _lastPostId = newPosts.lastOrNull?.id;
        _hasMore = newPosts.length == 20;
        state = AsyncValue.data(_posts);
      },
      error: (failure) => state = AsyncValue.error(failure, StackTrace.current),
    );
  }
}
```

### 3. Cache local

```dart
// Utiliser Hive pour le cache local
import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('posts_cache');
  }
  
  static Future<void> cachePosts(List<Post> posts) async {
    final box = Hive.box('posts_cache');
    await box.put('feed', posts.map((p) => p.toJson()).toList());
  }
  
  static List<Post>? getCachedPosts() {
    final box = Hive.box('posts_cache');
    final data = box.get('feed');
    if (data == null) return null;
    return (data as List).map((json) => Post.fromJson(json)).toList();
  }
}
```

### 4. Mode Offline

```dart
// Activer la persistance Firestore
FirebaseFirestore.instance.enablePersistence();

// Gérer l'état de connexion
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((result) {
    return result != ConnectivityResult.none;
  });
});
```

## 💰 Optimisation des coûts

### 1. Réduire les lectures Firestore

```dart
// ❌ MAUVAIS : Lecture à chaque build
Widget build(BuildContext context) {
  final user = ref.watch(userProvider(userId)); // Lecture à chaque rebuild
  return Text(user.value?.displayName ?? '');
}

// ✅ BON : Cache avec Riverpod
final userProvider = FutureProvider.family<User, String>((ref, userId) {
  return userRepository.getUserById(userId);
}); // Cache automatique
```

### 2. Batch operations

```dart
// Utiliser les transactions pour les opérations multiples
await firestore.runTransaction((transaction) async {
  // Plusieurs opérations en une seule transaction
  transaction.update(postRef, {'likesCount': FieldValue.increment(1)});
  transaction.update(userRef, {'totalLikes': FieldValue.increment(1)});
});
```

### 3. Limiter les requêtes

```dart
// Ne pas charger toutes les données d'un coup
// Utiliser la pagination
final posts = await getFeedPosts(limit: 20); // Pas 1000 !
```

### 4. Monitoring des coûts

- Configurer des alertes Firebase
- Surveiller les quotas quotidiens
- Analyser les coûts par fonctionnalité

## 🚀 Stratégies par phase

### Phase 1 : 0-10K utilisateurs (MVP)
- ✅ Pagination basique
- ✅ Index Firestore essentiels
- ✅ Compression d'images
- ✅ Cache Riverpod

### Phase 2 : 10K-100K utilisateurs
- 🔄 Cloud Functions pour notifications
- 🔄 Algolia pour la recherche
- 🔄 CDN pour les images
- 🔄 Cache local (Hive)

### Phase 3 : 100K-1M utilisateurs
- 🔄 Elasticsearch
- 🔄 Microservices (si nécessaire)
- 🔄 Load balancing
- 🔄 Database sharding

### Phase 4 : 1M+ utilisateurs
- 🔄 Architecture distribuée
- 🔄 Multi-région
- 🔄 Cache distribué (Redis)
- 🔄 Analytics avancés

## 📊 Monitoring et Analytics

### Métriques à surveiller

1. **Performance**
   - Temps de chargement des écrans
   - Temps de réponse Firestore
   - Taux d'erreur

2. **Utilisation**
   - Nombre de lectures/écritures Firestore
   - Taille des uploads Storage
   - Utilisation des Cloud Functions

3. **Expérience utilisateur**
   - Taux de rétention
   - Temps de session
   - Taux d'erreur utilisateur

### Outils recommandés

- **Firebase Performance Monitoring** : Performance de l'app
- **Firebase Analytics** : Comportement utilisateur
- **Firebase Crashlytics** : Erreurs et crashes
- **Custom Dashboards** : Métriques business

## 🔐 Sécurité à grande échelle

### 1. Rate Limiting

```javascript
// Cloud Function pour limiter les requêtes
exports.rateLimit = functions.https.onCall(async (data, context) => {
  const userId = context.auth.uid;
  const key = `rate_limit:${userId}`;
  
  // Utiliser Redis ou Firestore pour le comptage
  const count = await getCount(key);
  if (count > 100) { // 100 requêtes par heure
    throw new functions.https.HttpsError('resource-exhausted', 'Too many requests');
  }
  
  await incrementCount(key);
});
```

### 2. DDoS Protection

- Utiliser Firebase App Check
- Implémenter des CAPTCHAs pour les actions sensibles
- Limiter les requêtes par IP

### 3. Modération automatique

```javascript
// Utiliser ML pour détecter le contenu inapproprié
exports.autoModerate = functions.firestore
  .document('posts/{postId}')
  .onCreate(async (snap, context) => {
    const content = snap.data().content;
    
    // Utiliser Google Cloud Natural Language API
    const language = require('@google-cloud/language');
    const client = new language.LanguageServiceClient();
    
    const [result] = await client.analyzeSentiment({
      document: { content, type: 'PLAIN_TEXT' },
    });
    
    if (result.documentSentiment.score < -0.5) {
      // Contenu négatif, marquer pour modération
      await snap.ref.update({ needsModeration: true });
    }
  });
```

## 📝 Checklist de Scaling

### Immédiat (MVP)
- [x] Pagination des listes
- [x] Index Firestore de base
- [x] Compression d'images
- [ ] Monitoring de base

### Court terme (1-3 mois)
- [ ] Cloud Functions pour notifications
- [ ] Algolia pour recherche
- [ ] CDN pour images
- [ ] Cache local (Hive)
- [ ] Analytics avancés

### Moyen terme (3-6 mois)
- [ ] Modération automatique (ML)
- [ ] Rate limiting
- [ ] Optimisations Firestore avancées
- [ ] Mode offline complet

### Long terme (6+ mois)
- [ ] Elasticsearch
- [ ] Architecture multi-région
- [ ] Microservices si nécessaire
- [ ] Scaling horizontal

## 🎓 Ressources

- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Firebase Performance](https://firebase.google.com/docs/perf-mon)
- [Algolia Flutter](https://www.algolia.com/doc/guides/building-search-ui/getting-started/flutter/)
- [Flutter Performance](https://docs.flutter.dev/perf)

---

**Note** : Ce guide évolue avec le projet. Mettre à jour régulièrement selon les besoins réels.

