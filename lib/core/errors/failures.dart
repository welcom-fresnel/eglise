import 'package:equatable/equatable.dart';

/// Classe de base pour toutes les erreurs métier
/// 
/// Utilisée pour gérer les erreurs de manière typée et centralisée.
/// Permet de distinguer les erreurs réseau, de validation, d'authentification, etc.
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Erreur serveur (Firebase, réseau, etc.)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Erreur de cache/local
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Erreur de validation (données invalides)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Erreur d'authentification
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Erreur de permissions (utilisateur non autorisé)
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Erreur de modération (contenu bloqué)
class ModerationFailure extends Failure {
  const ModerationFailure(super.message);
}

