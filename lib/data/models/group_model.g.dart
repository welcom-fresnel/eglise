// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => GroupModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  churchName: json['churchName'] as String?,
  creatorId: json['creatorId'] as String,
  members:
      (json['members'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  moderators:
      (json['moderators'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  imageUrl: json['imageUrl'] as String?,
  isPrivate: json['isPrivate'] as bool? ?? false,
  createdAt: GroupModel._timestampFromJson(json['createdAt']),
  updatedAt: GroupModel._timestampFromJson(json['updatedAt']),
);

Map<String, dynamic> _$GroupModelToJson(GroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'churchName': instance.churchName,
      'creatorId': instance.creatorId,
      'members': instance.members,
      'moderators': instance.moderators,
      'imageUrl': instance.imageUrl,
      'isPrivate': instance.isPrivate,
      'createdAt': GroupModel._timestampToJson(instance.createdAt),
      'updatedAt': GroupModel._timestampToJson(instance.updatedAt),
    };
