import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../../core/config/cloudinary_config.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../core/utils/logger.dart';

/// Data source Cloudinary
///
/// Gère toutes les opérations d'upload/download d'images avec Cloudinary.
/// Implémentation manuelle de l'API Cloudinary avec http.
///
/// Cloudinary offre :
/// - Optimisation automatique des images
/// - Transformations à la volée
/// - CDN global
/// - Compression intelligente
class CloudinaryDataSource {
  /// Base URL de l'API Cloudinary
  static const String _baseUrl = 'https://api.cloudinary.com/v1_1';

  /// URL de base pour les images
  String get _imageBaseUrl =>
      'https://res.cloudinary.com/${CloudinaryConfig.cloudName}/image/upload';

  /// Upload une image vers Cloudinary
  ///
  /// [localPath] est le chemin local de l'image à uploader.
  /// [folder] est le dossier de destination (ex: 'profile_pictures', 'post_images').
  /// [publicId] est l'ID public de l'image (optionnel, généré automatiquement si null).
  /// [maxSizeKB] limite la taille de l'image (compression automatique).
  Future<Result<String>> uploadImage({
    required String localPath,
    required String folder,
    String? publicId,
    int? maxSizeKB,
  }) async {
    try {
      AppLogger.d('Upload image Cloudinary: $localPath -> $folder');

      final file = File(localPath);
      if (!await file.exists()) {
        return const Error(ValidationFailure('Fichier non trouvé'));
      }

      // Vérifier la taille du fichier
      final fileSize = await file.length();
      if (maxSizeKB != null && fileSize > maxSizeKB * 1024) {
        AppLogger.w('Fichier trop volumineux: ${fileSize / 1024} KB');
        // On continue quand même, Cloudinary compresse automatiquement
      }

      // Générer un publicId unique si non fourni
      final finalPublicId =
          publicId ??
          '${folder}/${DateTime.now().millisecondsSinceEpoch}_${fileSize}';

      // Lire le fichier
      final fileBytes = await file.readAsBytes();

      // Construire les paramètres
      final params = <String, String>{
        'folder': folder,
        'public_id': finalPublicId,
        'quality': 'auto',
        'fetch_format': 'auto',
        'overwrite': 'false',
      };

      // Si upload preset est configuré, l'utiliser (upload non signé)
      if (CloudinaryConfig.uploadPreset.isNotEmpty) {
        params['upload_preset'] = CloudinaryConfig.uploadPreset;
      } else {
        // Upload signé (nécessite signature)
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        params['timestamp'] = timestamp.toString();

        // Générer la signature
        final signature = _generateSignature(params);
        params['signature'] = signature;
        params['api_key'] = CloudinaryConfig.apiKey;
      }

      // Construire l'URL
      final url = Uri.parse(
        '$_baseUrl/${CloudinaryConfig.cloudName}/image/upload',
      );

      // Créer la requête multipart
      final request = http.MultipartRequest('POST', url);

      // Ajouter les paramètres
      params.forEach((key, value) {
        request.fields[key] = value;
      });

      // Ajouter le fichier
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: file.path.split('/').last,
        ),
      );

      // Envoyer la requête
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final secureUrl = jsonResponse['secure_url'] as String?;

        if (secureUrl != null) {
          AppLogger.d('Upload réussi: $secureUrl');
          return Success(secureUrl);
        } else {
          AppLogger.e('Upload réussi mais pas d\'URL retournée');
          return Error(ServerFailure('Pas d\'URL retournée par Cloudinary'));
        }
      } else {
        AppLogger.e('Upload échoué: ${response.statusCode} - ${response.body}');
        final error = json.decode(response.body);
        return Error(
          ServerFailure(
            'Erreur Cloudinary: ${error['error']?['message'] ?? response.body}',
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('Erreur lors de l\'upload Cloudinary', e, stackTrace);
      return Error(ServerFailure('Erreur inattendue: ${e.toString()}'));
    }
  }

  /// Upload une image avec transformation
  ///
  /// Permet d'appliquer des transformations Cloudinary lors de l'upload.
  Future<Result<String>> uploadImageWithTransformation({
    required String localPath,
    required String folder,
    Map<String, dynamic>? transformations,
    String? publicId,
  }) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) {
        return const Error(ValidationFailure('Fichier non trouvé'));
      }

      final finalPublicId =
          publicId ?? '${folder}/${DateTime.now().millisecondsSinceEpoch}';

      final fileBytes = await file.readAsBytes();

      // Construire les transformations
      final transformationParams = <String>[];
      if (transformations != null) {
        if (transformations.containsKey('width')) {
          transformationParams.add('w_${transformations['width']}');
        }
        if (transformations.containsKey('height')) {
          transformationParams.add('h_${transformations['height']}');
        }
        if (transformations.containsKey('crop')) {
          transformationParams.add('c_${transformations['crop']}');
        }
      }
      transformationParams.add('q_auto');
      transformationParams.add('f_auto');

      final transformation = transformationParams.join(',');

      final params = <String, String>{
        'folder': folder,
        'public_id': finalPublicId,
        'transformation': transformation,
        'overwrite': 'false',
      };

      if (CloudinaryConfig.uploadPreset.isNotEmpty) {
        params['upload_preset'] = CloudinaryConfig.uploadPreset;
      } else {
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        params['timestamp'] = timestamp.toString();
        params['signature'] = _generateSignature(params);
        params['api_key'] = CloudinaryConfig.apiKey;
      }

      final url = Uri.parse(
        '$_baseUrl/${CloudinaryConfig.cloudName}/image/upload',
      );
      final request = http.MultipartRequest('POST', url);

      params.forEach((key, value) {
        request.fields[key] = value;
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: file.path.split('/').last,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final secureUrl = jsonResponse['secure_url'] as String?;

        if (secureUrl != null) {
          AppLogger.d('Upload avec transformation réussi: $secureUrl');
          return Success(secureUrl);
        } else {
          return Error(ServerFailure('Pas d\'URL retournée par Cloudinary'));
        }
      } else {
        final error = json.decode(response.body);
        return Error(
          ServerFailure(
            'Erreur Cloudinary: ${error['error']?['message'] ?? response.body}',
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Erreur lors de l\'upload avec transformation',
        e,
        stackTrace,
      );
      return Error(ServerFailure('Erreur inattendue: ${e.toString()}'));
    }
  }

  /// Génère une URL optimisée pour une image existante
  ///
  /// Cloudinary permet de transformer les images à la volée via l'URL.
  /// Exemple : redimensionner, changer la qualité, etc.
  String getOptimizedUrl({
    required String publicId,
    int? width,
    int? height,
    String? quality,
    String? format,
    String? crop,
  }) {
    final transformations = <String>[];

    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    if (crop != null) transformations.add('c_$crop');
    transformations.add('q_${quality ?? 'auto'}');
    transformations.add('f_${format ?? 'auto'}');

    final transformation = transformations.join(',');

    // Si l'URL contient déjà le domaine Cloudinary, extraire le publicId
    String finalPublicId = publicId;
    if (publicId.contains('cloudinary.com')) {
      // Extraire le publicId de l'URL complète
      final uri = Uri.parse(publicId);
      final pathSegments = uri.pathSegments;
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex != -1 && uploadIndex < pathSegments.length - 1) {
        // Prendre tout après 'upload' comme publicId
        finalPublicId = pathSegments.sublist(uploadIndex + 1).join('/');
        // Enlever l'extension si présente
        finalPublicId = finalPublicId.replaceAll(RegExp(r'\.[^.]+$'), '');
      }
    }

    return '$_imageBaseUrl/$transformation/$finalPublicId';
  }

  /// Supprime une image de Cloudinary
  ///
  /// ⚠️ Nécessite l'API Secret. À faire côté serveur (Cloud Function) pour la sécurité.
  Future<Result<void>> deleteImage(String publicId) async {
    try {
      AppLogger.d('Suppression image Cloudinary: $publicId');

      // Extraire le publicId si c'est une URL complète
      String finalPublicId = publicId;
      if (publicId.contains('cloudinary.com')) {
        final uri = Uri.parse(publicId);
        final pathSegments = uri.pathSegments;
        final uploadIndex = pathSegments.indexOf('upload');
        if (uploadIndex != -1 && uploadIndex < pathSegments.length - 1) {
          finalPublicId = pathSegments.sublist(uploadIndex + 1).join('/');
          finalPublicId = finalPublicId.replaceAll(RegExp(r'\.[^.]+$'), '');
        }
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final params = <String, String>{
        'public_id': finalPublicId,
        'timestamp': timestamp.toString(),
      };

      final signature = _generateSignature(params);
      params['signature'] = signature;
      params['api_key'] = CloudinaryConfig.apiKey;

      final url = Uri.parse(
        '$_baseUrl/${CloudinaryConfig.cloudName}/image/destroy',
      );

      final response = await http.post(url, body: params);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['result'] == 'ok') {
          AppLogger.d('Image supprimée avec succès');
          return const Success(null);
        } else {
          return Error(ServerFailure('Suppression échouée'));
        }
      } else {
        final error = json.decode(response.body);
        return Error(
          ServerFailure(
            'Erreur Cloudinary: ${error['error']?['message'] ?? response.body}',
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('Erreur lors de la suppression', e, stackTrace);
      return Error(ServerFailure('Erreur inattendue: ${e.toString()}'));
    }
  }

  /// Upload un fichier générique (non-image)
  ///
  /// Pour les fichiers PDF, vidéos, etc.
  Future<Result<String>> uploadFile({
    required String localPath,
    required String folder,
    String resourceType = 'auto', // 'image', 'video', 'raw', 'auto'
    String? publicId,
  }) async {
    try {
      AppLogger.d('Upload fichier Cloudinary: $localPath -> $folder');

      final file = File(localPath);
      if (!await file.exists()) {
        return const Error(ValidationFailure('Fichier non trouvé'));
      }

      final finalPublicId =
          publicId ?? '${folder}/${DateTime.now().millisecondsSinceEpoch}';

      final fileBytes = await file.readAsBytes();

      final params = <String, String>{
        'folder': folder,
        'public_id': finalPublicId,
        'resource_type': resourceType,
        'overwrite': 'false',
      };

      if (CloudinaryConfig.uploadPreset.isNotEmpty) {
        params['upload_preset'] = CloudinaryConfig.uploadPreset;
      } else {
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        params['timestamp'] = timestamp.toString();
        params['signature'] = _generateSignature(params);
        params['api_key'] = CloudinaryConfig.apiKey;
      }

      final url = Uri.parse(
        '$_baseUrl/${CloudinaryConfig.cloudName}/$resourceType/upload',
      );

      final request = http.MultipartRequest('POST', url);
      params.forEach((key, value) {
        request.fields[key] = value;
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: file.path.split('/').last,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final secureUrl = jsonResponse['secure_url'] as String?;

        if (secureUrl != null) {
          AppLogger.d('Upload fichier réussi: $secureUrl');
          return Success(secureUrl);
        } else {
          return Error(ServerFailure('Pas d\'URL retournée par Cloudinary'));
        }
      } else {
        final error = json.decode(response.body);
        return Error(
          ServerFailure(
            'Erreur Cloudinary: ${error['error']?['message'] ?? response.body}',
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e('Erreur lors de l\'upload fichier', e, stackTrace);
      return Error(ServerFailure('Erreur inattendue: ${e.toString()}'));
    }
  }

  /// Génère la signature pour les uploads signés
  ///
  /// Cloudinary utilise SHA1 pour signer les requêtes.
  String _generateSignature(Map<String, String> params) {
    // Trier les paramètres par clé
    final sortedParams = params.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Construire la chaîne à signer
    final stringToSign = sortedParams
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    // Ajouter l'API Secret
    final stringToSignWithSecret = '$stringToSign${CloudinaryConfig.apiSecret}';

    // Générer le hash SHA1
    final bytes = utf8.encode(stringToSignWithSecret);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }
}
