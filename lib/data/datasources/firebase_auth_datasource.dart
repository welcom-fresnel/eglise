import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../core/utils/logger.dart';

/// Data source Firebase Authentication
/// 
/// Gère toutes les opérations d'authentification Firebase.
/// Cette couche est responsable de la communication directe avec Firebase.
class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSource(this._firebaseAuth);

  /// Stream des changements d'état d'authentification
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Récupère l'utilisateur actuellement connecté
  User? get currentUser => _firebaseAuth.currentUser;

  /// Connexion avec email et mot de passe
  Future<Result<FirebaseUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.i('Tentative de connexion: $email');
      
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Error(AuthFailure('Aucun utilisateur retourné'));
      }

      AppLogger.i('Connexion réussie: ${credential.user!.uid}');
      return Success(credential.user!);
    } on FirebaseAuthException catch (e) {
      AppLogger.e('Erreur de connexion Firebase', e);
      return Error(_mapFirebaseAuthException(e));
    } catch (e, stackTrace) {
      AppLogger.e('Erreur inattendue lors de la connexion', e, stackTrace);
      return Error(ServerFailure('Erreur inattendue: ${e.toString()}'));
    }
  }

  /// Inscription avec email et mot de passe
  Future<Result<FirebaseUser>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      AppLogger.i('Tentative d\'inscription: $email');
      
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Error(AuthFailure('Aucun utilisateur créé'));
      }

      // Mise à jour du nom d'affichage
      await credential.user!.updateDisplayName(displayName);
      await credential.user!.reload();
      final updatedUser = _firebaseAuth.currentUser;

      AppLogger.i('Inscription réussie: ${updatedUser?.uid}');
      return Success(updatedUser!);
    } on FirebaseAuthException catch (e) {
      AppLogger.e('Erreur d\'inscription Firebase', e);
      return Error(_mapFirebaseAuthException(e));
    } catch (e, stackTrace) {
      AppLogger.e('Erreur inattendue lors de l\'inscription', e, stackTrace);
      return Error(ServerFailure('Erreur inattendue: ${e.toString()}'));
    }
  }

  /// Déconnexion
  Future<Result<void>> signOut() async {
    try {
      AppLogger.i('Déconnexion de l\'utilisateur');
      await _firebaseAuth.signOut();
      return const Success(null);
    } catch (e, stackTrace) {
      AppLogger.e('Erreur lors de la déconnexion', e, stackTrace);
      return Error(ServerFailure('Erreur lors de la déconnexion: ${e.toString()}'));
    }
  }

  /// Réinitialisation du mot de passe
  Future<Result<void>> resetPassword(String email) async {
    try {
      AppLogger.i('Demande de réinitialisation de mot de passe: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      AppLogger.i('Email de réinitialisation envoyé');
      return const Success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.e('Erreur de réinitialisation Firebase', e);
      return Error(_mapFirebaseAuthException(e));
    } catch (e, stackTrace) {
      AppLogger.e('Erreur inattendue lors de la réinitialisation', e, stackTrace);
      return Error(ServerFailure('Erreur inattendue: ${e.toString()}'));
    }
  }

  /// Mappe les exceptions Firebase vers nos Failures
  Failure _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthFailure('Aucun utilisateur trouvé avec cet email.');
      case 'wrong-password':
        return const AuthFailure('Mot de passe incorrect.');
      case 'email-already-in-use':
        return const AuthFailure('Cet email est déjà utilisé.');
      case 'weak-password':
        return const AuthFailure('Le mot de passe est trop faible.');
      case 'invalid-email':
        return const AuthFailure('Email invalide.');
      case 'user-disabled':
        return const AuthFailure('Ce compte a été désactivé.');
      case 'too-many-requests':
        return const AuthFailure('Trop de tentatives. Réessayez plus tard.');
      case 'operation-not-allowed':
        return const AuthFailure('Opération non autorisée.');
      default:
        return AuthFailure('Erreur d\'authentification: ${e.message}');
    }
  }
}

/// Alias pour Firebase User (évite les conflits avec notre User entity)
typedef FirebaseUser = User;

