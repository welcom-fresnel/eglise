import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/post.dart';

part 'post_model.g.dart';

/// Modèle de données publication pour Firebase
@JsonSerializable()
class PostModel {
  final String id;
  final String authorId;
  final String content;
  final String type;
  final List<String> imageUrls;
  final String? bibleVerse;
  final String? bibleReference;
  final int likesCount;
  final int commentsCount;
  final List<String> likedBy;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime updatedAt;
  final String? groupId;
  final bool isReported;
  final bool isModerated;

  PostModel({
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

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  factory PostModel.fromEntity(Post post) {
    return PostModel(
      id: post.id,
      authorId: post.authorId,
      content: post.content,
      type: post.type,
      imageUrls: post.imageUrls,
      bibleVerse: post.bibleVerse,
      bibleReference: post.bibleReference,
      likesCount: post.likesCount,
      commentsCount: post.commentsCount,
      likedBy: post.likedBy,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
      groupId: post.groupId,
      isReported: post.isReported,
      isModerated: post.isModerated,
    );
  }

  Post toEntity() {
    return Post(
      id: id,
      authorId: authorId,
      content: content,
      type: type,
      imageUrls: imageUrls,
      bibleVerse: bibleVerse,
      bibleReference: bibleReference,
      likesCount: likesCount,
      commentsCount: commentsCount,
      likedBy: likedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      groupId: groupId,
      isReported: isReported,
      isModerated: isModerated,
    );
  }

  static DateTime _timestampFromJson(dynamic value) {
    if (value is Map && value['_seconds'] != null) {
      return DateTime.fromMillisecondsSinceEpoch(
        (value['_seconds'] as int) * 1000,
      );
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.parse(value.toString());
  }

  static dynamic _timestampToJson(DateTime value) {
    return value.millisecondsSinceEpoch;
  }
}

