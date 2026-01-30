import '../entities/comment.dart';
import '../../core/utils/result.dart';

/// Repository de commentaires
/// 
/// Définit le contrat pour la gestion des commentaires.
abstract class CommentRepository {
  /// Récupère les commentaires d'une publication
  /// 
  /// [lastCommentId] est utilisé pour la pagination.
  Future<Result<List<Comment>>> getPostComments({
    required String postId,
    String? lastCommentId,
    int limit = 50,
  });

  /// Crée un nouveau commentaire
  Future<Result<Comment>> createComment({
    required String postId,
    required String authorId,
    required String content,
  });

  /// Like/Unlike un commentaire
  Future<Result<Comment>> toggleLike({
    required String commentId,
    required String userId,
  });

  /// Signale un commentaire
  Future<Result<void>> reportComment({
    required String commentId,
    required String userId,
    required String reason,
  });

  /// Supprime un commentaire
  Future<Result<void>> deleteComment({
    required String commentId,
    required String userId,
  });
}

