import 'package:equatable/equatable.dart';

/// Entité publication du domaine
/// 
/// Représente une publication dans le fil d'actualité.
/// Peut être de type texte, image ou verset biblique.
class Post extends Equatable {
  final String id;
  final String authorId;
  final String content;
  final String type; // 'text', 'image', 'bible_verse'
  final List<String> imageUrls; // URLs des images si type = 'image'
  final String? bibleVerse; // Verset biblique si type = 'bible_verse'
  final String? bibleReference; // Référence (ex: "Jean 3:16")
  final int likesCount;
  final int commentsCount;
  final List<String> likedBy; // IDs des utilisateurs qui ont liké
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? groupId; // ID du groupe si publié dans un groupe
  final bool isReported;
  final bool isModerated; // Si modéré par un admin/modérateur

  const Post({
    required this.id,
    required this.authorId,
    required this.content,
    required this.type,
    this.imageUrls = const [],
    this.bibleVerse,
    this.bibleReference,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.likedBy = const [],
    required this.createdAt,
    required this.updatedAt,
    this.groupId,
    this.isReported = false,
    this.isModerated = false,
  });

  /// Vérifie si un utilisateur a liké cette publication
  bool isLikedBy(String userId) => likedBy.contains(userId);

  /// Crée une copie de la publication avec des champs modifiés
  Post copyWith({
    String? id,
    String? authorId,
    String? content,
    String? type,
    List<String>? imageUrls,
    String? bibleVerse,
    String? bibleReference,
    int? likesCount,
    int? commentsCount,
    List<String>? likedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? groupId,
    bool? isReported,
    bool? isModerated,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      type: type ?? this.type,
      imageUrls: imageUrls ?? this.imageUrls,
      bibleVerse: bibleVerse ?? this.bibleVerse,
      bibleReference: bibleReference ?? this.bibleReference,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      groupId: groupId ?? this.groupId,
      isReported: isReported ?? this.isReported,
      isModerated: isModerated ?? this.isModerated,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorId,
        content,
        type,
        imageUrls,
        bibleVerse,
        bibleReference,
        likesCount,
        commentsCount,
        likedBy,
        createdAt,
        updatedAt,
        groupId,
        isReported,
        isModerated,
      ];
}

