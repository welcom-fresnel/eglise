import '../entities/group.dart';
import '../../core/utils/result.dart';

/// Repository de groupes
/// 
/// Définit le contrat pour la gestion des groupes.
abstract class GroupRepository {
  /// Récupère tous les groupes publics
  Future<Result<List<Group>>> getPublicGroups({
    String? lastGroupId,
    int limit = 20,
  });

  /// Récupère les groupes d'un utilisateur
  Future<Result<List<Group>>> getUserGroups(String userId);

  /// Récupère un groupe par son ID
  Future<Result<Group>> getGroupById(String groupId);

  /// Crée un nouveau groupe
  Future<Result<Group>> createGroup({
    required String name,
    required String description,
    required String creatorId,
    String? churchName,
    bool isPrivate = false,
  });

  /// Rejoint un groupe
  Future<Result<Group>> joinGroup({
    required String groupId,
    required String userId,
  });

  /// Quitte un groupe
  Future<Result<void>> leaveGroup({
    required String groupId,
    required String userId,
  });

  /// Recherche des groupes
  Future<Result<List<Group>>> searchGroups(String query);
}

