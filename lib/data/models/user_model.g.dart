// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String,
  photoUrl: json['photoUrl'] as String?,
  bio: json['bio'] as String?,
  churchName: json['churchName'] as String?,
  role: json['role'] as String? ?? AppConstants.roleUser,
  createdAt: UserModel._timestampFromJson(json['createdAt']),
  updatedAt: UserModel._timestampFromJson(json['updatedAt']),
  isBlocked: json['isBlocked'] as bool? ?? false,
  blockedUsers:
      (json['blockedUsers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  groups:
      (json['groups'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'displayName': instance.displayName,
  'photoUrl': instance.photoUrl,
  'bio': instance.bio,
  'churchName': instance.churchName,
  'role': instance.role,
  'createdAt': UserModel._timestampToJson(instance.createdAt),
  'updatedAt': UserModel._timestampToJson(instance.updatedAt),
  'isBlocked': instance.isBlocked,
  'blockedUsers': instance.blockedUsers,
  'groups': instance.groups,
};
