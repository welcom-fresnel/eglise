// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
  id: json['id'] as String,
  authorId: json['authorId'] as String,
  content: json['content'] as String,
  type: json['type'] as String,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  bibleVerse: json['bibleVerse'] as String?,
  bibleReference: json['bibleReference'] as String?,
  likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
  commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
  likedBy:
      (json['likedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: PostModel._timestampFromJson(json['createdAt']),
  updatedAt: PostModel._timestampFromJson(json['updatedAt']),
  groupId: json['groupId'] as String?,
  isReported: json['isReported'] as bool? ?? false,
  isModerated: json['isModerated'] as bool? ?? false,
);

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
  'id': instance.id,
  'authorId': instance.authorId,
  'content': instance.content,
  'type': instance.type,
  'imageUrls': instance.imageUrls,
  'bibleVerse': instance.bibleVerse,
  'bibleReference': instance.bibleReference,
  'likesCount': instance.likesCount,
  'commentsCount': instance.commentsCount,
  'likedBy': instance.likedBy,
  'createdAt': PostModel._timestampToJson(instance.createdAt),
  'updatedAt': PostModel._timestampToJson(instance.updatedAt),
  'groupId': instance.groupId,
  'isReported': instance.isReported,
  'isModerated': instance.isModerated,
};
