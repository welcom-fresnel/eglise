import '../../repositories/auth_repository.dart';
import '../../entities/user.dart';
import '../../../core/utils/result.dart';
import '../../../core/errors/failures.dart';

/// Use case: Inscription d'un nouvel utilisateur
class SignUpUseCase {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  Future<Result<User>> call({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Validation
    if (email.isEmpty) {
      return const Error(ValidationFailure('L\'email est requis'));
    }

    if (password.isEmpty) {
      return const Error(ValidationFailure('Le mot de passe est requis'));
    }

    if (displayName.isEmpty) {
      return const Error(ValidationFailure('Le nom d\'affichage est requis'));
    }

    if (!_isValidEmail(email)) {
      return const Error(ValidationFailure('Format d\'email invalide'));
    }

    if (password.length < 6) {
      return const Error(ValidationFailure('Le mot de passe doit contenir au moins 6 caractères'));
    }

    if (displayName.length < 2) {
      return const Error(ValidationFailure('Le nom doit contenir au moins 2 caractères'));
    }

    if (displayName.length > 50) {
      return const Error(ValidationFailure('Le nom ne peut pas dépasser 50 caractères'));
    }

    // Appel au repository
    return await _authRepository.signUpWithEmailAndPassword(
      email: email.trim(),
      password: password,
      displayName: displayName.trim(),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

