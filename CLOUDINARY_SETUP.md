# ☁️ Configuration Cloudinary

Guide complet pour configurer Cloudinary dans le projet.

## 🎯 Pourquoi Cloudinary ?

Cloudinary offre plusieurs avantages par rapport à Firebase Storage :

- ✅ **Optimisation automatique** : Compression intelligente des images
- ✅ **Transformations à la volée** : Redimensionnement, crop, effets via URL
- ✅ **CDN global** : Images servies rapidement partout dans le monde
- ✅ **Format automatique** : WebP si supporté, fallback automatique
- ✅ **Coûts optimisés** : Plan gratuit généreux (25 GB storage, 25 GB bandwidth/mois)
- ✅ **API riche** : Transformations avancées, watermarking, etc.

## 📋 Prérequis

1. Compte Cloudinary (gratuit) : [https://cloudinary.com/users/register](https://cloudinary.com/users/register)
2. Flutter SDK installé
3. Dépendances installées : `http` et `crypto` (déjà dans `pubspec.yaml`)

## 🚀 Configuration étape par étape

### 1. Créer un compte Cloudinary

1. Aller sur [https://cloudinary.com/users/register](https://cloudinary.com/users/register)
2. S'inscrire avec email/password
3. Confirmer l'email
4. Se connecter au dashboard

### 2. Récupérer les credentials

Dans le dashboard Cloudinary :

1. Aller dans **Settings** (⚙️) → **Security**
2. Noter les informations suivantes :
   - **Cloud Name** : Votre nom de cloud (ex: `dxy8vxyz`)
   - **API Key** : Votre clé API
   - **API Secret** : Votre secret API (⚠️ à garder secret !)

### 3. Configurer l'application

#### Option A : Configuration directe (développement)

Éditer `lib/core/config/cloudinary_config.dart` :

```dart
class CloudinaryConfig {
  CloudinaryConfig._();

  // Remplacer par vos vraies clés
  static const String cloudName = 'votre-cloud-name';
  static const String apiKey = 'votre-api-key';
  static const String apiSecret = 'votre-api-secret';
  
  static const String uploadPreset = ''; // Optionnel
  static const bool secure = true;
  static const String cdnSubdomain = 'res';
}
```

#### Option B : Variables d'environnement (recommandé pour production)

1. Installer `flutter_dotenv` :
   ```yaml
   dependencies:
     flutter_dotenv: ^5.1.0
   ```

2. Créer un fichier `.env` à la racine :
   ```env
   CLOUDINARY_CLOUD_NAME=votre-cloud-name
   CLOUDINARY_API_KEY=votre-api-key
   CLOUDINARY_API_SECRET=votre-api-secret
   ```

3. Ajouter `.env` au `.gitignore` :
   ```
   .env
   ```

4. Modifier `cloudinary_config.dart` :
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';

   class CloudinaryConfig {
     CloudinaryConfig._();

     static String get cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
     static String get apiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
     static String get apiSecret => dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
     
     static const String uploadPreset = '';
     static const bool secure = true;
     static const String cdnSubdomain = 'res';
   }
   ```

5. Charger dans `main.dart` :
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';

   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     // Charger les variables d'environnement
     await dotenv.load(fileName: ".env");
     
     // ... reste du code
   }
   ```

### 4. Configurer les Upload Presets (optionnel mais recommandé)

Les Upload Presets permettent d'uploader des images sans signer côté client (plus sécurisé).

1. Dans Cloudinary Dashboard → **Settings** → **Upload**
2. Cliquer sur **Add upload preset**
3. Configurer :
   - **Preset name** : `eglise_unsigned` (ou autre)
   - **Signing mode** : `Unsigned`
   - **Folder** : `eglise/` (optionnel)
   - **Allowed formats** : `jpg, png, webp`
   - **Max file size** : `10 MB`
   - **Transformations** : 
     ```
     quality:auto
     fetch_format:auto
     ```
4. Sauvegarder

5. Mettre à jour `cloudinary_config.dart` :
   ```dart
   static const String uploadPreset = 'eglise_unsigned';
   ```

### 5. Tester la configuration

Créer un test simple :

```dart
// test/cloudinary_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:eglise/core/config/cloudinary_config.dart';
import 'package:eglise/data/datasources/cloudinary_datasource.dart';

void main() {
  test('Cloudinary configuration should be valid', () {
    expect(CloudinaryConfig.cloudName, isNotEmpty);
    expect(CloudinaryConfig.apiKey, isNotEmpty);
    expect(CloudinaryConfig.apiSecret, isNotEmpty);
  });

  test('CloudinaryDataSource should initialize', () {
    final datasource = CloudinaryDataSource();
    expect(datasource, isNotNull);
  });
}
```

## 📁 Structure des dossiers Cloudinary

Organisation recommandée :

```
eglise/
├── profile_pictures/     # Photos de profil
│   └── {userId}/        # Par utilisateur
├── post_images/          # Images des posts
│   └── {postId}/        # Par post
└── group_images/         # Images de groupes (futur)
    └── {groupId}/
```

## 🔒 Sécurité

### ⚠️ Important : Ne jamais exposer l'API Secret côté client !

Pour les uploads non signés (recommandé) :

1. Utiliser un **Upload Preset** avec mode `Unsigned`
2. L'API Secret reste côté serveur uniquement
3. L'API Key peut être publique (mais pas nécessaire avec unsigned preset)

### Upload signé vs non signé

**Upload non signé (recommandé)** :
- Utilise un Upload Preset
- Pas besoin de l'API Secret côté client
- Plus simple et sécurisé
- Limité par les règles du preset

**Upload signé** :
- Nécessite l'API Secret
- Plus de contrôle
- Mais expose le secret si mal configuré
- À éviter côté client

## 🎨 Transformations Cloudinary

Cloudinary permet des transformations à la volée via l'URL :

### Exemples d'utilisation

```dart
// Dans votre code
final cloudinary = CloudinaryDataSource();

// URL optimisée pour avatar (150x150)
final avatarUrl = cloudinary.getOptimizedUrl(
  publicId: 'profile_pictures/user123',
  width: 150,
  height: 150,
  quality: 'auto',
  format: 'auto', // WebP si supporté
);

// URL pour image de post (largeur max 800px)
final postImageUrl = cloudinary.getOptimizedUrl(
  publicId: 'post_images/post456/image1',
  width: 800,
  quality: 'auto',
);
```

### Transformations disponibles

- **Redimensionnement** : `width`, `height`, `crop`
- **Qualité** : `quality: auto` (optimisation automatique)
- **Format** : `fetch_format: auto` (WebP si supporté)
- **Effets** : `blur`, `brightness`, `contrast`, etc.
- **Watermarking** : Ajout de watermark automatique
- **Face detection** : Détection et crop automatique des visages

Voir la [documentation Cloudinary](https://cloudinary.com/documentation/image_transformations) pour plus d'options.

## 📊 Monitoring et Analytics

Dans le dashboard Cloudinary :

- **Media Library** : Voir toutes les images uploadées
- **Usage** : Statistiques d'utilisation (storage, bandwidth)
- **Analytics** : Performance et transformations

## 🧪 Tester l'upload

Exemple de code pour tester :

```dart
import 'package:image_picker/image_picker.dart';
import 'package:eglise/data/datasources/cloudinary_datasource.dart';

// Dans votre widget
final picker = ImagePicker();
final image = await picker.pickImage(source: ImageSource.gallery);

if (image != null) {
  final cloudinary = CloudinaryDataSource();
  final result = await cloudinary.uploadImage(
    localPath: image.path,
    folder: 'profile_pictures',
    publicId: 'profile_pictures/user123',
    maxSizeKB: 2000,
  );
  
  result.when(
    success: (url) {
      print('Image uploadée: $url');
      // Utiliser l'URL pour mettre à jour le profil
    },
    error: (failure) {
      print('Erreur: ${failure.message}');
    },
  );
}
```

## 🐛 Dépannage

### Erreur : "Invalid API credentials"

- Vérifier que les clés sont correctes dans `cloudinary_config.dart`
- Vérifier que le Cloud Name est correct

### Erreur : "Upload preset not found"

- Vérifier que l'Upload Preset existe dans le dashboard
- Vérifier que le nom est correct (case-sensitive)

### Images trop lentes à charger

- Vérifier que les transformations sont appliquées
- Utiliser `quality: auto` et `fetch_format: auto`
- Vérifier le CDN dans les settings

### Erreur : "File too large"

- Vérifier la limite dans l'Upload Preset
- Compresser l'image avant upload si nécessaire

## 📚 Ressources

- [Documentation Cloudinary](https://cloudinary.com/documentation)
- [Cloudinary Flutter SDK](https://pub.dev/packages/cloudinary_flutter)
- [Transformations d'images](https://cloudinary.com/documentation/image_transformations)
- [Upload Presets](https://cloudinary.com/documentation/upload_presets)

## ✅ Checklist de configuration

- [ ] Compte Cloudinary créé
- [ ] Credentials récupérés (Cloud Name, API Key, API Secret)
- [ ] `cloudinary_config.dart` configuré
- [ ] Upload Preset créé (optionnel mais recommandé)
- [ ] Test d'upload réussi
- [ ] Variables d'environnement configurées (si utilisé)
- [ ] `.env` ajouté au `.gitignore`

---

**Configuration terminée ! Vous pouvez maintenant utiliser Cloudinary pour tous vos uploads d'images.** 🎉

