import '../../repositories/auth_repository.dart';
import '../../entities/user.dart';
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';

/// Use case: Connexion d'un utilisateur
/// 
/// Encapsule la logique métier de connexion.
/// Valide les données d'entrée avant d'appeler le repository.
class SignInUseCase {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  Future<Result<User>> call({
    required String email,
    required String password,
  }) async {
    // Validation
    if (email.isEmpty) {
      return const Error(ValidationFailure('L\'email est requis'));
    }

    if (password.isEmpty) {
      return const Error(ValidationFailure('Le mot de passe est requis'));
    }

    if (!_isValidEmail(email)) {
      return const Error(ValidationFailure('Format d\'email invalide'));
    }

    if (password.length < 6) {
      return const Error(ValidationFailure('Le mot de passe doit contenir au moins 6 caractères'));
    }

    // Appel au repository
    return await _authRepository.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

