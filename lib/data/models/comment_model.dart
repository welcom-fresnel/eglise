import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/comment.dart';

part 'comment_model.g.dart';

/// Modèle de données commentaire pour Firebase
@JsonSerializable()
class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String content;
  final int likesCount;
  final List<String> likedBy;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime updatedAt;
  final bool isReported;
  final bool isModerated;

  CommentModel({
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

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);

  factory CommentModel.fromEntity(Comment comment) {
    return CommentModel(
      id: comment.id,
      postId: comment.postId,
      authorId: comment.authorId,
      content: comment.content,
      likesCount: comment.likesCount,
      likedBy: comment.likedBy,
      createdAt: comment.createdAt,
      updatedAt: comment.updatedAt,
      isReported: comment.isReported,
      isModerated: comment.isModerated,
    );
  }

  Comment toEntity() {
    return Comment(
      id: id,
      postId: postId,
      authorId: authorId,
      content: content,
      likesCount: likesCount,
      likedBy: likedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
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

