import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/result.dart';
import '../../core/utils/logger.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/firestore_datasource.dart';
import '../models/user_model.dart';

/// Implémentation du repository d'authentification
/// 
/// Utilise Firebase Auth pour l'authentification et Firestore
/// pour créer/récupérer le profil utilisateur.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _authDataSource;
  final FirestoreDataSource _firestoreDataSource;

  AuthRepositoryImpl(
    this._authDataSource,
    this._firestoreDataSource,
  );

  @override
  Stream<User?> get authStateChanges {
    return _authDataSource.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserFromFirebaseUser(firebaseUser);
    });
  }

  @override
  Future<Result<User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final result = await _authDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return result.when(
      success: (firebaseUser) async {
        final user = await _getUserFromFirebaseUser(firebaseUser);
        return Success(user);
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final result = await _authDataSource.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );

    return result.when(
      success: (firebaseUser) async {
        // Créer le profil utilisateur dans Firestore
        final now = DateTime.now();
        final user = User(
          id: firebaseUser.uid,
          email: email,
          displayName: displayName,
          role: AppConstants.roleUser,
          createdAt: now,
          updatedAt: now,
        );

        final createResult = await _createUserInFirestore(user);
        return createResult.when(
          success: (_) => Success(user),
          error: (failure) => Error(failure),
        );
      },
      error: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<void>> signOut() {
    return _authDataSource.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _authDataSource.currentUser;
    if (firebaseUser == null) return null;
    return await _getUserFromFirebaseUser(firebaseUser);
  }

  @override
  Future<Result<void>> resetPassword(String email) {
    return _authDataSource.resetPassword(email);
  }

  /// Récupère l'utilisateur depuis Firestore à partir d'un FirebaseUser
  Future<User> _getUserFromFirebaseUser(FirebaseUser firebaseUser) async {
    final result = await _firestoreDataSource.getDocument(
      collection: AppConstants.usersCollection,
      documentId: firebaseUser.uid,
    );

    return result.when(
      success: (data) {
        final userModel = UserModel.fromJson({
          'id': firebaseUser.uid,
          ...data,
        });
        return userModel.toEntity();
      },
      error: (_) {
        // Si l'utilisateur n'existe pas encore dans Firestore, créer un profil par défaut
        AppLogger.w('Utilisateur non trouvé dans Firestore, création du profil');
        final now = DateTime.now();
        return User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'Utilisateur',
          photoUrl: firebaseUser.photoURL,
          role: AppConstants.roleUser,
          createdAt: now,
          updatedAt: now,
        );
      },
    );
  }

  /// Crée un utilisateur dans Firestore
  Future<Result<void>> _createUserInFirestore(User user) async {
    final userModel = UserModel.fromEntity(user);
    return await _firestoreDataSource.createDocument(
      collection: AppConstants.usersCollection,
      documentId: user.id,
      data: userModel.toJson(),
    );
  }
}

