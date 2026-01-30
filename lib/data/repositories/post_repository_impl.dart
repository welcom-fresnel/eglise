import 'package:uuid/uuid.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/result.dart';
import '../../core/utils/logger.dart';
import '../datasources/firestore_datasource.dart';
import '../models/post_model.dart';

/// Implémentation du repository de publications
class PostRepositoryImpl implements PostRepository {
  final FirestoreDataSource _firestoreDataSource;
  final _uuid = const Uuid();

  PostRepositoryImpl(this._firestoreDataSource);

  @override
  Future<Result<List<Post>>> getFeedPosts({
    String? lastPostId,
    int limit = 20,
  }) async {
    final result = await _firestoreDataSource.getDocuments(
      collection: AppConstants.postsCollection,
      lastDocumentId: lastPostId,
      limit: limit,
      orderBy: 'createdAt',
      descending: true,
      whereConditions: {
        'isModerated': false, // Exclure les posts modérés
      },
    );

    return result.when(
      success: (documents) {
        final posts = documents
            .map((data) => PostModel.fromJson(data).toEntity())
            .toList();
        return Success(posts);
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<List<Post>>> getUserPosts({
    required String userId,
    String? lastPostId,
    int limit = 20,
  }) async {
    final result = await _firestoreDataSource.getDocuments(
      collection: AppConstants.postsCollection,
      lastDocumentId: lastPostId,
      limit: limit,
      orderBy: 'createdAt',
      descending: true,
      whereConditions: {
        'authorId': userId,
        'isModerated': false,
      },
    );

    return result.when(
      success: (documents) {
        final posts = documents
            .map((data) => PostModel.fromJson(data).toEntity())
            .toList();
        return Success(posts);
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<List<Post>>> getGroupPosts({
    required String groupId,
    String? lastPostId,
    int limit = 20,
  }) async {
    final result = await _firestoreDataSource.getDocuments(
      collection: AppConstants.postsCollection,
      lastDocumentId: lastPostId,
      limit: limit,
      orderBy: 'createdAt',
      descending: true,
      whereConditions: {
        'groupId': groupId,
        'isModerated': false,
      },
    );

    return result.when(
      success: (documents) {
        final posts = documents
            .map((data) => PostModel.fromJson(data).toEntity())
            .toList();
        return Success(posts);
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<Post>> createPost({
    required String authorId,
    required String content,
    required String type,
    List<String>? imageUrls,
    String? bibleVerse,
    String? bibleReference,
    String? groupId,
  }) async {
    final now = DateTime.now();
    final postId = _uuid.v4();

    final post = Post(
      id: postId,
      authorId: authorId,
      content: content,
      type: type,
      imageUrls: imageUrls ?? [],
      bibleVerse: bibleVerse,
      bibleReference: bibleReference,
      createdAt: now,
      updatedAt: now,
      groupId: groupId,
    );

    final postModel = PostModel.fromEntity(post);
    final result = await _firestoreDataSource.createDocument(
      collection: AppConstants.postsCollection,
      documentId: postId,
      data: postModel.toJson(),
    );

    return result.when(
      success: (_) => Success(post),
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<Post>> toggleLike({
    required String postId,
    required String userId,
  }) async {
    // Récupérer le post
    final getResult = await _firestoreDataSource.getDocument(
      collection: AppConstants.postsCollection,
      documentId: postId,
    );

    return getResult.when(
      success: (data) async {
        final postModel = PostModel.fromJson({
          'id': postId,
          ...data,
        });
        var post = postModel.toEntity();

        // Toggle like
        final isLiked = post.isLikedBy(userId);
        final updatedLikedBy = isLiked
            ? post.likedBy.where((id) => id != userId).toList()
            : [...post.likedBy, userId];

        final updatedPost = post.copyWith(
          likedBy: updatedLikedBy,
          likesCount: isLiked ? post.likesCount - 1 : post.likesCount + 1,
          updatedAt: DateTime.now(),
        );

        // Mettre à jour dans Firestore
        final updateResult = await _firestoreDataSource.updateDocument(
          collection: AppConstants.postsCollection,
          documentId: postId,
          data: PostModel.fromEntity(updatedPost).toJson(),
        );

        return updateResult.when(
          success: (_) => Success(updatedPost),
          error: (failure) => Error(failure),
        );
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<void>> reportPost({
    required String postId,
    required String userId,
    required String reason,
  }) async {
    // Créer un rapport dans la collection reports
    final reportId = _uuid.v4();
    final reportData = {
      'id': reportId,
      'type': 'post',
      'targetId': postId,
      'reportedBy': userId,
      'reason': reason,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'status': 'pending',
    };

    final createReportResult = await _firestoreDataSource.createDocument(
      collection: AppConstants.reportsCollection,
      documentId: reportId,
      data: reportData,
    );

    return createReportResult.when(
      success: (_) async {
        // Marquer le post comme signalé
        final updateResult = await _firestoreDataSource.updateDocument(
          collection: AppConstants.postsCollection,
          documentId: postId,
          data: {'isReported': true},
        );
        return updateResult;
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<void>> deletePost({
    required String postId,
    required String userId,
  }) async {
    // Vérifier que l'utilisateur est l'auteur ou un modérateur
    final getResult = await _firestoreDataSource.getDocument(
      collection: AppConstants.postsCollection,
      documentId: postId,
    );

    return getResult.when(
      success: (data) async {
        final postModel = PostModel.fromJson({
          'id': postId,
          ...data,
        });
        final post = postModel.toEntity();

        // TODO: Vérifier les permissions (auteur ou modérateur)
        // Pour l'instant, on vérifie juste si c'est l'auteur
        if (post.authorId != userId) {
          return const Error(
            PermissionFailure('Vous n\'êtes pas autorisé à supprimer ce post'),
          );
        }

        return await _firestoreDataSource.deleteDocument(
          collection: AppConstants.postsCollection,
          documentId: postId,
        );
      },
      error: (failure) => Error(failure),
    );
  }
}

