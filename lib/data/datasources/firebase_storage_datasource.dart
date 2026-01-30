import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../core/utils/logger.dart';

/// Data source Firebase Storage
/// 
/// Gère toutes les opérations d'upload/download de fichiers.
class FirebaseStorageDataSource {
  final FirebaseStorage _storage;

  FirebaseStorageDataSource(this._storage);

  /// Upload un fichier vers Firebase Storage
  /// 
  /// [localPath] est le chemin local du fichier à uploader.
  /// [storagePath] est le chemin de destination dans Storage.
  Future<Result<String>> uploadFile({
    required String localPath,
    required String storagePath,
  }) async {
    try {
      AppLogger.d('Upload fichier: $localPath -> $storagePath');
      
      final file = File(localPath);
      if (!await file.exists()) {
        return const Error(ValidationFailure('Fichier non trouvé'));
      }

      final ref = _storage.ref().child(storagePath);
      await ref.putFile(file);

      final downloadUrl = await ref.getDownloadURL();
      
      AppLogger.d('Upload réussi: $downloadUrl');
      return Success(downloadUrl);
    } on FirebaseException catch (e) {
      AppLogger.e('Erreur Firebase Storage', e);
      return Error(ServerFailure('Erreur Storage: ${e.message}'));
    } catch (e, stackTrace) {
      AppLogger.e('Erreur lors de l\'upload', e, stackTrace);
      return Error(ServerFailure('Erreur inattendue: ${e.toString()}'));
    }
  }

  /// Upload un fichier avec compression
  /// 
  /// Pour les images, on peut ajouter de la compression ici.
  Future<Result<String>> uploadImage({
    required String localPath,
    required String storagePath,
    int? maxSizeKB,
  }) async {
    // TODO: Ajouter la compression d'image si nécessaire
    // Pour l'instant, on utilise uploadFile directement
    return uploadFile(localPath: localPath, storagePath: storagePath);
  }

  /// Supprime un fichier de Storage
  Future<Result<void>> deleteFile(String storagePath) async {
    try {
      AppLogger.d('Suppression fichier: $storagePath');
      
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
      
      AppLogger.d('Fichier supprimé avec succès');
      return const Success(null);
    } on FirebaseException catch (e) {
      AppLogger.e('Erreur Firebase Storage', e);
      return Error(ServerFailure('Erreur Storage: ${e.message}'));
    } catch (e, stackTrace) {
      AppLogger.e('Erreur lors de la suppression', e, stackTrace);
      return Error(ServerFailure('Erreur inattendue: ${e.toString()}'));
    }
  }

  /// Récupère l'URL de téléchargement d'un fichier
  Future<Result<String>> getDownloadUrl(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final url = await ref.getDownloadURL();
      return Success(url);
    } on FirebaseException catch (e) {
      AppLogger.e('Erreur Firebase Storage', e);
      return Error(ServerFailure('Erreur Storage: ${e.message}'));
    } catch (e, stackTrace) {
      AppLogger.e('Erreur lors de la récupération de l\'URL', e, stackTrace);
      return Error(ServerFailure('Erreur inattendue: ${e.toString()}'));
    }
  }
}

