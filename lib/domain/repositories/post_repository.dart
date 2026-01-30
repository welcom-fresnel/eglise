import '../entities/post.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';

/// Repository de publications
/// 
/// Définit le contrat pour la gestion des publications.
abstract class PostRepository {
  /// Récupère les publications du fil d'actualité
  /// 
  /// [lastPostId] est utilisé pour la pagination.
  /// Retourne les publications les plus récentes en premier.
  Future<Result<List<Post>>> getFeedPosts({
    String? lastPostId,
    int limit = 20,
  });

  /// Récupère les publications d'un utilisateur
  Future<Result<List<Post>>> getUserPosts({
    required String userId,
    String? lastPostId,
    int limit = 20,
  });

  /// Récupère les publications d'un groupe
  Future<Result<List<Post>>> getGroupPosts({
    required String groupId,
    String? lastPostId,
    int limit = 20,
  });

  /// Crée une nouvelle publication
  Future<Result<Post>> createPost({
    required String authorId,
    required String content,
    required String type,
    List<String>? imageUrls,
    String? bibleVerse,
    String? bibleReference,
    String? groupId,
  });

  /// Like/Unlike une publication
  Future<Result<Post>> toggleLike({
    required String postId,
    required String userId,
  });

  /// Signale une publication
  Future<Result<void>> reportPost({
    required String postId,
    required String userId,
    required String reason,
  });

  /// Supprime une publication
  Future<Result<void>> deletePost({
    required String postId,
    required String userId,
  });
}

