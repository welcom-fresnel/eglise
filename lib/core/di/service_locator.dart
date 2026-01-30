import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';

import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/firestore_datasource.dart';
import '../../data/datasources/cloudinary_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../data/repositories/comment_repository_impl.dart';
import '../../data/repositories/group_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../domain/repositories/group_repository.dart';
import '../../domain/usecases/auth/sign_in_usecase.dart';
import '../../domain/usecases/auth/sign_up_usecase.dart';
import '../../domain/usecases/posts/create_post_usecase.dart';

/// Service Locator (Dependency Injection)
/// 
/// Centralise l'injection de dépendances avec GetIt.
/// Toutes les dépendances sont enregistrées ici.
final sl = GetIt.instance;

/// Initialise toutes les dépendances
Future<void> init() async {
  // Sur le web, Firebase n'est pas disponible - skip
  if (!kIsWeb) {
    // ===== Firebase Instances =====
    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

    // ===== Data Sources =====
    sl.registerLazySingleton<FirebaseAuthDataSource>(
      () => FirebaseAuthDataSource(sl<FirebaseAuth>()),
    );
    sl.registerLazySingleton<FirestoreDataSource>(
      () => FirestoreDataSource(sl<FirebaseFirestore>()),
    );
  }
  
  sl.registerLazySingleton<CloudinaryDataSource>(
    () => CloudinaryDataSource(),
  );

  // ===== Repositories =====
  if (!kIsWeb) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        sl<FirebaseAuthDataSource>(),
        sl<FirestoreDataSource>(),
      ),
    );
    sl.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(
        sl<FirestoreDataSource>(),
        sl<CloudinaryDataSource>(),
      ),
    );
    sl.registerLazySingleton<PostRepository>(
      () => PostRepositoryImpl(sl<FirestoreDataSource>()),
    );
    sl.registerLazySingleton<CommentRepository>(
      () => CommentRepositoryImpl(sl<FirestoreDataSource>()),
    );
    sl.registerLazySingleton<GroupRepository>(
      () => GroupRepositoryImpl(sl<FirestoreDataSource>()),
    );

    // ===== Use Cases =====
    sl.registerLazySingleton(() => SignInUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => SignUpUseCase(sl<AuthRepository>()));
  }
  
  sl.registerLazySingleton(() => CreatePostUseCase(sl<PostRepository>()));
}

