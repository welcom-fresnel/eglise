import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/group.dart';

part 'group_model.g.dart';

/// Modèle de données groupe pour Firebase
@JsonSerializable()
class GroupModel {
  final String id;
  final String name;
  final String description;
  final String? churchName;
  final String creatorId;
  final List<String> members;
  final List<String> moderators;
  final String? imageUrl;
  final bool isPrivate;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime updatedAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    this.churchName,
    required this.creatorId,
    this.members = const [],
    this.moderators = const [],
    this.imageUrl,
    this.isPrivate = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroupModelToJson(this);

  factory GroupModel.fromEntity(Group group) {
    return GroupModel(
      id: group.id,
      name: group.name,
      description: group.description,
      churchName: group.churchName,
      creatorId: group.creatorId,
      members: group.members,
      moderators: group.moderators,
      imageUrl: group.imageUrl,
      isPrivate: group.isPrivate,
      createdAt: group.createdAt,
      updatedAt: group.updatedAt,
    );
  }

  Group toEntity() {
    return Group(
      id: id,
      name: name,
      description: description,
      churchName: churchName,
      creatorId: creatorId,
      members: members,
      moderators: moderators,
      imageUrl: imageUrl,
      isPrivate: isPrivate,
      createdAt: createdAt,
      updatedAt: updatedAt,
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

