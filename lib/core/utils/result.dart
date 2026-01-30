import 'failures.dart';

/// Type Result pour gérer les erreurs de manière fonctionnelle
/// 
/// Similaire à Either en programmation fonctionnelle.
/// Left = erreur (Failure), Right = succès (T)
sealed class Result<T> {
  const Result();
}

/// Succès avec une valeur
class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

/// Erreur avec un Failure
class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}

/// Extensions pour faciliter l'utilisation
extension ResultExtensions<T> on Result<T> {
  /// Retourne true si c'est un succès
  bool get isSuccess => this is Success<T>;
  
  /// Retourne true si c'est une erreur
  bool get isError => this is Error<T>;
  
  /// Récupère la valeur si succès, null sinon
  T? get valueOrNull => switch (this) {
    Success(value: final v) => v,
    Error() => null,
  };
  
  /// Récupère le failure si erreur, null sinon
  Failure? get failureOrNull => switch (this) {
    Success() => null,
    Error(failure: final f) => f,
  };
  
  /// Pattern matching pour gérer les deux cas (succès/erreur)
  R when<R>({
    required R Function(T) success,
    required R Function(Failure) error,
  }) {
    return switch (this) {
      Success(value: final v) => success(v),
      Error(failure: final f) => error(f),
    };
  }
}

