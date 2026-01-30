import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/sign_in_usecase.dart';
import '../../domain/usecases/auth/sign_up_usecase.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/result.dart';

/// Provider pour l'état d'authentification
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = sl<AuthRepository>();
  return authRepository.authStateChanges;
});

/// Provider pour l'utilisateur actuel
final currentUserProvider = FutureProvider<User?>((ref) async {
  final authRepository = sl<AuthRepository>();
  return await authRepository.getCurrentUser();
});

/// Provider pour le use case de connexion
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return sl<SignInUseCase>();
});

/// Provider pour le use case d'inscription
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return sl<SignUpUseCase>();
});

/// Notifier pour gérer l'état de connexion
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final AuthRepository _authRepository;

  AuthNotifier(
    this._signInUseCase,
    this._signUpUseCase,
    this._authRepository,
  ) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final user = await _authRepository.getCurrentUser();
    state = AsyncValue.data(user);
  }

  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final result = await _signInUseCase(
      email: email,
      password: password,
    );

    result.when(
      success: (user) {
        state = AsyncValue.data(user);
      },
      error: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );

    return result;
  }

  Future<Result<User>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    final result = await _signUpUseCase(
      email: email,
      password: password,
      displayName: displayName,
    );

    result.when(
      success: (user) {
        state = AsyncValue.data(user);
      },
      error: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );

    return result;
  }

  Future<Result<void>> signOut() async {
    final result = await _authRepository.signOut();
    result.when(
      success: (_) {
        state = const AsyncValue.data(null);
      },
      error: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );
    return result;
  }
}

/// Provider pour le notifier d'authentification
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(
    sl<SignInUseCase>(),
    sl<SignUpUseCase>(),
    sl<AuthRepository>(),
  );
});

