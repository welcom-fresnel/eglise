import 'package:equatable/equatable.dart';

/// Entité utilisateur du domaine
/// 
/// Représente un utilisateur dans la logique métier.
/// Ne contient que les données essentielles, sans dépendances techniques.
/// 
/// Cette entité est indépendante de Firebase et peut être utilisée
/// avec n'importe quelle source de données.
class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final String? churchName;
  final String role; // 'user', 'moderator', 'admin'
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isBlocked;
  final List<String> blockedUsers; // IDs des utilisateurs bloqués
  final List<String> groups; // IDs des groupes

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio,
    this.churchName,
    this.role = 'user',
    required this.createdAt,
    required this.updatedAt,
    this.isBlocked = false,
    this.blockedUsers = const [],
    this.groups = const [],
  });

  /// Vérifie si l'utilisateur est modérateur ou admin
  bool get isModerator => role == 'moderator' || role == 'admin';
  
  /// Vérifie si l'utilisateur est admin
  bool get isAdmin => role == 'admin';

  /// Crée une copie de l'utilisateur avec des champs modifiés
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? bio,
    String? churchName,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isBlocked,
    List<String>? blockedUsers,
    List<String>? groups,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      churchName: churchName ?? this.churchName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isBlocked: isBlocked ?? this.isBlocked,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      groups: groups ?? this.groups,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        bio,
        churchName,
        role,
        createdAt,
        updatedAt,
        isBlocked,
        blockedUsers,
        groups,
      ];
}

