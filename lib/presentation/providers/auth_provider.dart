import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/sign_in_usecase.dart';
import '../../domain/usecases/auth/sign_up_usecase.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';

/// Provider pour l'état d'authentification
final authStateProvider = StreamProvider<User?>((ref) {
  if (kIsWeb) {
    // Sur le web, pas d'authentification Firebase
    return Stream.value(null);
  }
  final authRepository = sl<AuthRepository>();
  return authRepository.authStateChanges;
});

/// Provider pour l'utilisateur actuel
final currentUserProvider = FutureProvider<User?>((ref) async {
  if (kIsWeb) {
    // Sur le web, pas d'authentification Firebase
    return null;
  }
  final authRepository = sl<AuthRepository>();
  return await authRepository.getCurrentUser();
});

/// Provider pour le use case de connexion
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  if (kIsWeb) {
    // Sur le web, retourner un dummy use case
    return _WebDummySignInUseCase();
  }
  return sl<SignInUseCase>();
});

/// Provider pour le use case d'inscription
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  if (kIsWeb) {
    // Sur le web, retourner un dummy use case
    return _WebDummySignUpUseCase();
  }
  return sl<SignUpUseCase>();
});

/// Provider pour la connexion
final signInProvider = FutureProvider.family<Result<User>, ({String email, String password})>((ref, params) async {
  final useCase = sl<SignInUseCase>();
  return await useCase(email: params.email, password: params.password);
});

/// Provider pour l'inscription
final signUpProvider = FutureProvider.family<Result<User>, ({String email, String password, String displayName})>((ref, params) async {
  final useCase = sl<SignUpUseCase>();
  return await useCase(email: params.email, password: params.password, displayName: params.displayName);
});

/// Provider pour la déconnexion
final signOutProvider = FutureProvider<Result<void>>((ref) async {
  final repository = sl<AuthRepository>();
  return await repository.signOut();
});

/// Provider dummy pour compatibilité - les screens utilisent authNotifierProvider.notifier
/// mais nous ne gérons que des FutureProviders maintenant
class _DummyNotifier {
  final AuthRepository _authRepository;
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;

  _DummyNotifier(this._authRepository, this._signInUseCase, this._signUpUseCase);

  Future<Result<User>> signIn({required String email, required String password}) async {
    return await _signInUseCase(email: email, password: password);
  }

  Future<Result<User>> signUp({required String email, required String password, required String displayName}) async {
    return await _signUpUseCase(email: email, password: password, displayName: displayName);
  }

  Future<Result<void>> signOut() async {
    return await _authRepository.signOut();
  }
}

/// Provider pour le notifier (compatibilité avec le code existant)
final authNotifierProvider = Provider<_DummyNotifier>((ref) {
  if (kIsWeb) {
    // Sur le web, retourner un dummy notifier qui n'a pas besoin de Firebase
    return _DummyNotifier(
      _WebDummyAuthRepository(),
      _WebDummySignInUseCase(),
      _WebDummySignUpUseCase(),
    );
  }
  
  return _DummyNotifier(
    sl<AuthRepository>(),
    sl<SignInUseCase>(),
    sl<SignUpUseCase>(),
  );
});

// ===== Dummy classes pour le web =====

// Variable simple pour stocker l'utilisateur connecté sur le web
User? _webCurrentUser;
const String _testEmail = 'test@example.com';
const String _testPassword = 'password123';

class _WebDummyAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => Stream.value(_webCurrentUser);

  @override
  Future<Result<void>> resetPassword(String email) async {
    return Success(null);
  }

  @override
  Future<Result<User>> signInWithEmailAndPassword({required String email, required String password}) async {
    // Simple test: accept test@example.com with password123
    if (email == _testEmail && password == _testPassword) {
      _webCurrentUser = User(
        id: 'test-user-id',
        email: email,
        displayName: 'Test User',
        photoUrl: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return Success(_webCurrentUser!);
    }
    return Error(ValidationFailure('Invalid credentials'));
  }

  @override
  Future<Result<User>> signUpWithEmailAndPassword({required String email, required String password, required String displayName}) async {
    // Simple test: accept any valid email/password
    if (email.isNotEmpty && password.length >= 6) {
      _webCurrentUser = User(
        id: 'new-user-id-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName,
        photoUrl: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return Success(_webCurrentUser!);
    }
    return Error(ValidationFailure('Invalid email or password too short'));
  }

  @override
  Future<Result<void>> signOut() async {
    _webCurrentUser = null;
    return Success(null);
  }

  @override
  Future<User?> getCurrentUser() async {
    return _webCurrentUser;
  }
}

class _WebDummySignInUseCase extends SignInUseCase {
  _WebDummySignInUseCase() : super(_WebDummyAuthRepository());

  @override
  Future<Result<User>> call({required String email, required String password}) async {
    return await super.call(email: email, password: password);
  }
}

class _WebDummySignUpUseCase extends SignUpUseCase {
  _WebDummySignUpUseCase() : super(_WebDummyAuthRepository());

  @override
  Future<Result<User>> call({required String email, required String password, required String displayName}) async {
    return await super.call(email: email, password: password, displayName: displayName);
  }
}