import '../../repositories/post_repository.dart';
import '../../entities/post.dart';
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';
import '../../../core/constants/app_constants.dart';

/// Use case: Création d'une publication
class CreatePostUseCase {
  final PostRepository _postRepository;

  CreatePostUseCase(this._postRepository);

  Future<Result<Post>> call({
    required String authorId,
    required String content,
    required String type,
    List<String>? imageUrls,
    String? bibleVerse,
    String? bibleReference,
    String? groupId,
  }) async {
    // Validation
    if (content.isEmpty) {
      return const Error(ValidationFailure('Le contenu ne peut pas être vide'));
    }

    if (content.length > AppConstants.maxPostLength) {
      return Error(ValidationFailure(
        'Le contenu ne peut pas dépasser ${AppConstants.maxPostLength} caractères',
      ));
    }

    if (!_isValidPostType(type)) {
      return const Error(ValidationFailure('Type de publication invalide'));
    }

    // Validation spécifique selon le type
    if (type == AppConstants.postTypeBibleVerse) {
      if (bibleVerse == null || bibleVerse.isEmpty) {
        return const Error(ValidationFailure('Le verset biblique est requis'));
      }
      if (bibleReference == null || bibleReference.isEmpty) {
        return const Error(ValidationFailure('La référence biblique est requise'));
      }
    }

    if (type == AppConstants.postTypeImage) {
      if (imageUrls == null || imageUrls.isEmpty) {
        return const Error(ValidationFailure('Au moins une image est requise'));
      }
    }

    // Appel au repository
    return await _postRepository.createPost(
      authorId: authorId,
      content: content.trim(),
      type: type,
      imageUrls: imageUrls,
      bibleVerse: bibleVerse?.trim(),
      bibleReference: bibleReference?.trim(),
      groupId: groupId,
    );
  }

  bool _isValidPostType(String type) {
    return [
      AppConstants.postTypeText,
      AppConstants.postTypeImage,
      AppConstants.postTypeBibleVerse,
    ].contains(type);
  }
}

