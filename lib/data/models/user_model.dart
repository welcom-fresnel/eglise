import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';
import '../../core/constants/app_constants.dart';

part 'user_model.g.dart';

/// Modèle de données utilisateur pour Firebase
/// 
/// Représente la structure JSON stockée dans Firestore.
/// Utilise json_serializable pour la sérialisation automatique.
@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final String? churchName;
  final String role;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime updatedAt;
  final bool isBlocked;
  final List<String> blockedUsers;
  final List<String> groups;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio,
    this.churchName,
    this.role = AppConstants.roleUser,
    required this.createdAt,
    required this.updatedAt,
    this.isBlocked = false,
    this.blockedUsers = const [],
    this.groups = const [],
  });

  /// Convertit depuis JSON (Firestore)
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convertit vers JSON (Firestore)
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Convertit depuis une entité User du domaine
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      bio: user.bio,
      churchName: user.churchName,
      role: user.role,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isBlocked: user.isBlocked,
      blockedUsers: user.blockedUsers,
      groups: user.groups,
    );
  }

  /// Convertit vers une entité User du domaine
  User toEntity() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      bio: bio,
      churchName: churchName,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isBlocked: isBlocked,
      blockedUsers: blockedUsers,
      groups: groups,
    );
  }

  // Helpers pour la conversion Timestamp <-> DateTime
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

