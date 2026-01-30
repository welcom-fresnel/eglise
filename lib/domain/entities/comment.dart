import 'package:equatable/equatable.dart';

/// Entité commentaire du domaine
/// 
/// Représente un commentaire sur une publication.
class Comment extends Equatable {
  final String id;
  final String postId;
  final String authorId;
  final String content;
  final int likesCount;
  final List<String> likedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isReported;
  final bool isModerated;

  const Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    this.likesCount = 0,
    this.likedBy = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isReported = false,
    this.isModerated = false,
  });

  /// Vérifie si un utilisateur a liké ce commentaire
  bool isLikedBy(String userId) => likedBy.contains(userId);

  /// Crée une copie du commentaire avec des champs modifiés
  Comment copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? content,
    int? likesCount,
    List<String>? likedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isReported,
    bool? isModerated,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isReported: isReported ?? this.isReported,
      isModerated: isModerated ?? this.isModerated,
    );
  }

  @override
  List<Object?> get props => [
        id,
        postId,
        authorId,
        content,
        likesCount,
        likedBy,
        createdAt,
        updatedAt,
        isReported,
        isModerated,
      ];
}

