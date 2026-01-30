import '../entities/user.dart';
import '../../core/utils/result.dart';

/// Repository d'authentification
/// 
/// Définit le contrat pour l'authentification des utilisateurs.
/// L'implémentation sera dans la couche data.
/// 
/// Cette abstraction permet de changer facilement de backend
/// sans modifier la logique métier.
abstract class AuthRepository {
  /// Connexion avec email et mot de passe
  /// 
  /// Retourne l'utilisateur connecté ou une Failure en cas d'erreur.
  Future<Result<User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Inscription avec email et mot de passe
  /// 
  /// Crée un nouvel utilisateur et le connecte automatiquement.
  Future<Result<User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Déconnexion
  Future<Result<void>> signOut();

  /// Récupère l'utilisateur actuellement connecté
  /// 
  /// Retourne null si aucun utilisateur n'est connecté.
  Future<User?> getCurrentUser();

  /// Stream de l'état d'authentification
  /// 
  /// Émet l'utilisateur connecté ou null si déconnecté.
  Stream<User?> get authStateChanges;

  /// Réinitialisation du mot de passe
  Future<Result<void>> resetPassword(String email);
}

