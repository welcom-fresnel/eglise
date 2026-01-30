import '../entities/user.dart';
import '../../core/utils/result.dart';

/// Repository utilisateur
/// 
/// Définit le contrat pour la gestion des utilisateurs.
abstract class UserRepository {
  /// Récupère un utilisateur par son ID
  Future<Result<User>> getUserById(String userId);

  /// Met à jour le profil utilisateur
  Future<Result<User>> updateUser(User user);

  /// Met à jour la photo de profil
  /// 
  /// [imagePath] est le chemin local de l'image à uploader.
  Future<Result<String>> updateProfilePicture({
    required String userId,
    required String imagePath,
  });

  /// Bloque un utilisateur
  Future<Result<void>> blockUser({
    required String currentUserId,
    required String userIdToBlock,
  });

  /// Débloque un utilisateur
  Future<Result<void>> unblockUser({
    required String currentUserId,
    required String userIdToUnblock,
  });

  /// Recherche des utilisateurs par nom
  Future<Result<List<User>>> searchUsers(String query);
}

