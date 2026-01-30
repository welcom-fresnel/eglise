// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
  id: json['id'] as String,
  postId: json['postId'] as String,
  authorId: json['authorId'] as String,
  content: json['content'] as String,
  likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
  likedBy:
      (json['likedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: CommentModel._timestampFromJson(json['createdAt']),
  updatedAt: CommentModel._timestampFromJson(json['updatedAt']),
  isReported: json['isReported'] as bool? ?? false,
  isModerated: json['isModerated'] as bool? ?? false,
);

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'postId': instance.postId,
      'authorId': instance.authorId,
      'content': instance.content,
      'likesCount': instance.likesCount,
      'likedBy': instance.likedBy,
      'createdAt': CommentModel._timestampToJson(instance.createdAt),
      'updatedAt': CommentModel._timestampToJson(instance.updatedAt),
      'isReported': instance.isReported,
      'isModerated': instance.isModerated,
    };
