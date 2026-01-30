import 'package:uuid/uuid.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/result.dart';
import '../datasources/firestore_datasource.dart';
import '../models/comment_model.dart';

/// Implémentation du repository de commentaires
class CommentRepositoryImpl implements CommentRepository {
  final FirestoreDataSource _firestoreDataSource;
  final _uuid = const Uuid();

  CommentRepositoryImpl(this._firestoreDataSource);

  @override
  Future<Result<List<Comment>>> getPostComments({
    required String postId,
    String? lastCommentId,
    int limit = 50,
  }) async {
    final result = await _firestoreDataSource.getDocuments(
      collection: AppConstants.commentsCollection,
      lastDocumentId: lastCommentId,
      limit: limit,
      orderBy: 'createdAt',
      descending: false, // Plus anciens en premier pour les commentaires
      whereConditions: {
        'postId': postId,
        'isModerated': false,
      },
    );

    return result.when(
      success: (documents) {
        final comments = documents
            .map((data) => CommentModel.fromJson(data).toEntity())
            .toList();
        return Success(comments);
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<Comment>> createComment({
    required String postId,
    required String authorId,
    required String content,
  }) async {
    final now = DateTime.now();
    final commentId = _uuid.v4();

    final comment = Comment(
      id: commentId,
      postId: postId,
      authorId: authorId,
      content: content,
      createdAt: now,
      updatedAt: now,
    );

    final commentModel = CommentModel.fromEntity(comment);
    final result = await _firestoreDataSource.createDocument(
      collection: AppConstants.commentsCollection,
      documentId: commentId,
      data: commentModel.toJson(),
    );

    return result.when(
      success: (_) async {
        // Incrémenter le compteur de commentaires du post
        await _firestoreDataSource.incrementField(
          collection: AppConstants.postsCollection,
          documentId: postId,
          field: 'commentsCount',
          value: 1,
        );
        return Success(comment);
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<Comment>> toggleLike({
    required String commentId,
    required String userId,
  }) async {
    final getResult = await _firestoreDataSource.getDocument(
      collection: AppConstants.commentsCollection,
      documentId: commentId,
    );

    return getResult.when(
      success: (data) async {
        final commentModel = CommentModel.fromJson({
          'id': commentId,
          ...data,
        });
        var comment = commentModel.toEntity();

        final isLiked = comment.isLikedBy(userId);
        final updatedLikedBy = isLiked
            ? comment.likedBy.where((id) => id != userId).toList()
            : [...comment.likedBy, userId];

        final updatedComment = comment.copyWith(
          likedBy: updatedLikedBy,
          likesCount: isLiked ? comment.likesCount - 1 : comment.likesCount + 1,
          updatedAt: DateTime.now(),
        );

        final updateResult = await _firestoreDataSource.updateDocument(
          collection: AppConstants.commentsCollection,
          documentId: commentId,
          data: CommentModel.fromEntity(updatedComment).toJson(),
        );

        return updateResult.when(
          success: (_) => Success(updatedComment),
          error: (failure) => Error(failure),
        );
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<void>> reportComment({
    required String commentId,
    required String userId,
    required String reason,
  }) async {
    final reportId = _uuid.v4();
    final reportData = {
      'id': reportId,
      'type': 'comment',
      'targetId': commentId,
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
        final updateResult = await _firestoreDataSource.updateDocument(
          collection: AppConstants.commentsCollection,
          documentId: commentId,
          data: {'isReported': true},
        );
        return updateResult;
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<void>> deleteComment({
    required String commentId,
    required String userId,
  }) async {
    final getResult = await _firestoreDataSource.getDocument(
      collection: AppConstants.commentsCollection,
      documentId: commentId,
    );

    return getResult.when(
      success: (data) async {
        final commentModel = CommentModel.fromJson({
          'id': commentId,
          ...data,
        });
        final comment = commentModel.toEntity();

        if (comment.authorId != userId) {
          return const Error(
            PermissionFailure('Vous n\'êtes pas autorisé à supprimer ce commentaire'),
          );
        }

        // Décrémenter le compteur de commentaires du post
        await _firestoreDataSource.incrementField(
          collection: AppConstants.postsCollection,
          documentId: comment.postId,
          field: 'commentsCount',
          value: -1,
        );

        return await _firestoreDataSource.deleteDocument(
          collection: AppConstants.commentsCollection,
          documentId: commentId,
        );
      },
      error: (failure) => Error(failure),
    );
  }
}

