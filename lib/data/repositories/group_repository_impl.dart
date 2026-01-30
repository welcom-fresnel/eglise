import 'package:uuid/uuid.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/result.dart';
import '../datasources/firestore_datasource.dart';
import '../models/group_model.dart';

/// Implémentation du repository de groupes
class GroupRepositoryImpl implements GroupRepository {
  final FirestoreDataSource _firestoreDataSource;
  final _uuid = const Uuid();

  GroupRepositoryImpl(this._firestoreDataSource);

  @override
  Future<Result<List<Group>>> getPublicGroups({
    String? lastGroupId,
    int limit = 20,
  }) async {
    final result = await _firestoreDataSource.getDocuments(
      collection: AppConstants.groupsCollection,
      lastDocumentId: lastGroupId,
      limit: limit,
      orderBy: 'createdAt',
      descending: true,
      whereConditions: {
        'isPrivate': false,
      },
    );

    return result.when(
      success: (documents) {
        final groups = documents
            .map((data) => GroupModel.fromJson(data).toEntity())
            .toList();
        return Success(groups);
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<List<Group>>> getUserGroups(String userId) async {
    // Récupérer tous les groupes et filtrer ceux où l'utilisateur est membre
    final result = await _firestoreDataSource.getDocuments(
      collection: AppConstants.groupsCollection,
      limit: 100,
      orderBy: 'createdAt',
      descending: true,
    );

    return result.when(
      success: (documents) {
        final groups = documents
            .map((data) => GroupModel.fromJson(data).toEntity())
            .where((group) => group.isMember(userId))
            .toList();
        return Success(groups);
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<Group>> getGroupById(String groupId) async {
    final result = await _firestoreDataSource.getDocument(
      collection: AppConstants.groupsCollection,
      documentId: groupId,
    );

    return result.when(
      success: (data) {
        final groupModel = GroupModel.fromJson({
          'id': groupId,
          ...data,
        });
        return Success(groupModel.toEntity());
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<Group>> createGroup({
    required String name,
    required String description,
    required String creatorId,
    String? churchName,
    bool isPrivate = false,
  }) async {
    final now = DateTime.now();
    final groupId = _uuid.v4();

    final group = Group(
      id: groupId,
      name: name,
      description: description,
      churchName: churchName,
      creatorId: creatorId,
      members: [creatorId], // Le créateur est automatiquement membre
      moderators: [creatorId], // Le créateur est automatiquement modérateur
      isPrivate: isPrivate,
      createdAt: now,
      updatedAt: now,
    );

    final groupModel = GroupModel.fromEntity(group);
    final result = await _firestoreDataSource.createDocument(
      collection: AppConstants.groupsCollection,
      documentId: groupId,
      data: groupModel.toJson(),
    );

    return result.when(
      success: (_) => Success(group),
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<Group>> joinGroup({
    required String groupId,
    required String userId,
  }) async {
    final getResult = await getGroupById(groupId);
    return getResult.when(
      success: (group) async {
        if (group.isMember(userId)) {
          return Success(group); // Déjà membre
        }

        final updatedMembers = [...group.members, userId];
        final updatedGroup = group.copyWith(
          members: updatedMembers,
          updatedAt: DateTime.now(),
        );

        final updateResult = await _firestoreDataSource.updateDocument(
          collection: AppConstants.groupsCollection,
          documentId: groupId,
          data: GroupModel.fromEntity(updatedGroup).toJson(),
        );

        return updateResult.when(
          success: (_) => Success(updatedGroup),
          error: (failure) => Error(failure),
        );
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<void>> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    final getResult = await getGroupById(groupId);
    return getResult.when(
      success: (group) async {
        if (!group.isMember(userId)) {
          return const Success(null); // Pas membre
        }

        // Ne pas permettre au créateur de quitter le groupe
        if (group.creatorId == userId) {
          return const Error(
            ValidationFailure('Le créateur du groupe ne peut pas le quitter'),
          );
        }

        final updatedMembers = group.members.where((id) => id != userId).toList();
        final updatedModerators = group.moderators.where((id) => id != userId).toList();
        
        final updatedGroup = group.copyWith(
          members: updatedMembers,
          moderators: updatedModerators,
          updatedAt: DateTime.now(),
        );

        final updateResult = await _firestoreDataSource.updateDocument(
          collection: AppConstants.groupsCollection,
          documentId: groupId,
          data: GroupModel.fromEntity(updatedGroup).toJson(),
        );

        return updateResult;
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<List<Group>>> searchGroups(String query) async {
    if (query.isEmpty) {
      return const Success([]);
    }

    final result = await _firestoreDataSource.getDocuments(
      collection: AppConstants.groupsCollection,
      limit: 50,
      orderBy: 'name',
      descending: false,
      whereConditions: {
        'isPrivate': false,
      },
    );

    return result.when(
      success: (documents) {
        final groups = documents
            .map((data) => GroupModel.fromJson(data).toEntity())
            .where((group) => 
                group.name.toLowerCase().contains(query.toLowerCase()) ||
                (group.description.toLowerCase().contains(query.toLowerCase())))
            .toList();
        return Success(groups);
      },
      error: (failure) => Error(failure),
    );
  }
}

