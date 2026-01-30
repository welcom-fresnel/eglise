import 'package:equatable/equatable.dart';

/// Entité groupe du domaine
/// 
/// Représente un groupe (groupe de prière, groupe par église, etc.).
class Group extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? churchName; // Si groupe lié à une église
  final String creatorId;
  final List<String> members; // IDs des membres
  final List<String> moderators; // IDs des modérateurs du groupe
  final String? imageUrl;
  final bool isPrivate; // Si le groupe est privé
  final DateTime createdAt;
  final DateTime updatedAt;

  const Group({
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

  /// Vérifie si un utilisateur est membre du groupe
  bool isMember(String userId) => members.contains(userId);

  /// Vérifie si un utilisateur est modérateur du groupe
  bool isModerator(String userId) => moderators.contains(userId);

  /// Crée une copie du groupe avec des champs modifiés
  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? churchName,
    String? creatorId,
    List<String>? members,
    List<String>? moderators,
    String? imageUrl,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      churchName: churchName ?? this.churchName,
      creatorId: creatorId ?? this.creatorId,
      members: members ?? this.members,
      moderators: moderators ?? this.moderators,
      imageUrl: imageUrl ?? this.imageUrl,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        churchName,
        creatorId,
        members,
        moderators,
        imageUrl,
        isPrivate,
        createdAt,
        updatedAt,
      ];
}

