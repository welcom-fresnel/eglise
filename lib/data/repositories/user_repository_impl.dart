import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../datasources/firestore_datasource.dart';
import '../datasources/cloudinary_datasource.dart';
import '../models/user_model.dart';

/// Implémentation du repository utilisateur
class UserRepositoryImpl implements UserRepository {
  final FirestoreDataSource _firestoreDataSource;
  final CloudinaryDataSource _cloudinaryDataSource;

  UserRepositoryImpl(
    this._firestoreDataSource,
    this._cloudinaryDataSource,
  );

  @override
  Future<Result<User>> getUserById(String userId) async {
    final result = await _firestoreDataSource.getDocument(
      collection: AppConstants.usersCollection,
      documentId: userId,
    );

    return result.when(
      success: (data) {
        final userModel = UserModel.fromJson({
          'id': userId,
          ...data,
        });
        return Success(userModel.toEntity());
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<User>> updateUser(User user) async {
    final updatedUser = user.copyWith(updatedAt: DateTime.now());
    final userModel = UserModel.fromEntity(updatedUser);
    
    final result = await _firestoreDataSource.updateDocument(
      collection: AppConstants.usersCollection,
      documentId: user.id,
      data: userModel.toJson(),
    );

    return result.when(
      success: (_) => Success(updatedUser),
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<String>> updateProfilePicture({
    required String userId,
    required String imagePath,
  }) async {
    // Upload l'image vers Cloudinary
    // Le publicId sera généré automatiquement : profile_pictures/userId/timestamp
    final uploadResult = await _cloudinaryDataSource.uploadImage(
      localPath: imagePath,
      folder: AppConstants.profilePicturesPath,
      publicId: '${AppConstants.profilePicturesPath}/$userId',
      maxSizeKB: 2000, // 2 MB max
    );

    return uploadResult.when(
      success: (downloadUrl) async {
        // Mettre à jour le profil utilisateur avec la nouvelle URL
        final userResult = await getUserById(userId);
        return userResult.when(
          success: (user) async {
            final updatedUser = user.copyWith(photoUrl: downloadUrl);
            final updateResult = await updateUser(updatedUser);
            return updateResult.when(
              success: (_) => Success(downloadUrl),
              error: (failure) => Error(failure),
            );
          },
          error: (failure) => Error(failure),
        );
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<void>> blockUser({
    required String currentUserId,
    required String userIdToBlock,
  }) async {
    if (currentUserId == userIdToBlock) {
      return const Error(ValidationFailure('Vous ne pouvez pas vous bloquer vous-même'));
    }

    final userResult = await getUserById(currentUserId);
    return userResult.when(
      success: (user) async {
        if (user.blockedUsers.contains(userIdToBlock)) {
          return const Success(null); // Déjà bloqué
        }

        final updatedBlockedUsers = [...user.blockedUsers, userIdToBlock];
        final updatedUser = user.copyWith(blockedUsers: updatedBlockedUsers);
        final updateResult = await updateUser(updatedUser);
        return updateResult.when(
          success: (_) => const Success(null),
          error: (failure) => Error(failure),
        );
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<void>> unblockUser({
    required String currentUserId,
    required String userIdToUnblock,
  }) async {
    final userResult = await getUserById(currentUserId);
    return userResult.when(
      success: (user) async {
        if (!user.blockedUsers.contains(userIdToUnblock)) {
          return const Success(null); // Pas bloqué
        }

        final updatedBlockedUsers = user.blockedUsers
            .where((id) => id != userIdToUnblock)
            .toList();
        final updatedUser = user.copyWith(blockedUsers: updatedBlockedUsers);
        final updateResult = await updateUser(updatedUser);
        return updateResult.when(
          success: (_) => const Success(null),
          error: (failure) => Error(failure),
        );
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<List<User>>> searchUsers(String query) async {
    if (query.isEmpty) {
      return const Success([]);
    }

    // Recherche simple par nom d'affichage
    // Pour une recherche plus avancée, utiliser Algolia ou Elasticsearch
    final result = await _firestoreDataSource.getDocuments(
      collection: AppConstants.usersCollection,
      limit: 50,
      orderBy: 'displayName',
      descending: false,
    );

    return result.when(
      success: (documents) {
        final users = documents
            .map((data) => UserModel.fromJson(data).toEntity())
            .where((user) => user.displayName
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
        return Success(users);
      },
      error: (failure) => Error(failure),
    );
  }
}

