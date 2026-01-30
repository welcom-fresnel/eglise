# 🤝 Guide de Contribution

Merci de votre intérêt pour contribuer au projet ! Ce guide vous aidera à comprendre comment contribuer efficacement.

## 📋 Table des matières

- [Code de conduite](#-code-de-conduite)
- [Comment contribuer](#-comment-contribuer)
- [Standards de code](#-standards-de-code)
- [Processus de Pull Request](#-processus-de-pull-request)
- [Tests](#-tests)
- [Documentation](#-documentation)

## 📜 Code de conduite

### Nos valeurs

- **Respect** : Traiter tous les membres avec respect et bienveillance
- **Bienveillance** : Créer un environnement accueillant pour tous
- **Excellence** : Viser la qualité dans chaque contribution
- **Collaboration** : Travailler ensemble pour atteindre nos objectifs

### Comportement attendu

- Être respectueux et inclusif
- Accepter les critiques constructives
- Se concentrer sur ce qui est le mieux pour la communauté
- Montrer de l'empathie envers les autres membres

## 🚀 Comment contribuer

### 1. Signaler un bug

Si vous trouvez un bug :

1. Vérifier qu'il n'existe pas déjà une issue
2. Créer une nouvelle issue avec :
   - Description claire du problème
   - Étapes pour reproduire
   - Comportement attendu vs comportement actuel
   - Captures d'écran si applicable
   - Version de Flutter/Dart

### 2. Proposer une fonctionnalité

Pour proposer une nouvelle fonctionnalité :

1. Vérifier qu'elle n'existe pas déjà
2. Créer une issue avec le label "enhancement"
3. Décrire :
   - Le problème que cela résout
   - La solution proposée
   - Les cas d'usage
   - Les impacts potentiels

### 3. Contribuer du code

#### Workflow Git

```bash
# 1. Fork le projet
# 2. Cloner votre fork
git clone https://github.com/votre-username/eglise.git
cd eglise

# 3. Créer une branche
git checkout -b feature/ma-fonctionnalite

# 4. Faire vos modifications
# ... coder ...

# 5. Commit avec un message clair
git commit -m "feat: ajouter fonctionnalité X"

# 6. Push vers votre fork
git push origin feature/ma-fonctionnalite

# 7. Créer une Pull Request sur GitHub
```

#### Convention de nommage des branches

- `feature/nom-fonctionnalite` : Nouvelle fonctionnalité
- `fix/nom-bug` : Correction de bug
- `refactor/nom-refactoring` : Refactoring
- `docs/nom-documentation` : Documentation
- `test/nom-test` : Tests

#### Convention de commit

Utiliser [Conventional Commits](https://www.conventionalcommits.org/) :

```
<type>(<scope>): <description>

[body optionnel]

[footer optionnel]
```

Types :
- `feat` : Nouvelle fonctionnalité
- `fix` : Correction de bug
- `docs` : Documentation
- `style` : Formatage (pas de changement de code)
- `refactor` : Refactoring
- `test` : Tests
- `chore` : Tâches de maintenance

Exemples :
```
feat(auth): ajouter connexion avec Google
fix(posts): corriger pagination du feed
docs(readme): mettre à jour instructions d'installation
refactor(repositories): simplifier logique de cache
```

## 📝 Standards de code

### Architecture

- Suivre la **Clean Architecture**
- Respecter la séparation des couches (domain, data, presentation)
- Ne pas créer de dépendances circulaires

### Style de code

- Suivre les [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Utiliser `dart format` avant chaque commit
- Respecter les règles du linter (`flutter analyze`)

### Exemple de code

```dart
// ✅ BON : Code clair et documenté
/// Récupère les publications du fil d'actualité
/// 
/// [lastPostId] est utilisé pour la pagination.
Future<Result<List<Post>>> getFeedPosts({
  String? lastPostId,
  int limit = 20,
}) async {
  // Implémentation
}

// ❌ MAUVAIS : Code non documenté et peu clair
Future<List> getPosts(String? id, int l) async {
  // ...
}
```

### Bonnes pratiques

1. **Documentation** : Commenter les fonctions complexes
2. **Types** : Utiliser des types forts (éviter `dynamic`)
3. **Null safety** : Gérer les valeurs nulles explicitement
4. **Erreurs** : Utiliser `Result<T>` pour gérer les erreurs
5. **Validation** : Valider dans les use cases
6. **Tests** : Écrire des tests pour la logique métier

## 🔄 Processus de Pull Request

### Avant de créer une PR

1. ✅ Code formaté (`dart format`)
2. ✅ Pas d'erreurs de linter (`flutter analyze`)
3. ✅ Tests passent (`flutter test`)
4. ✅ Documentation à jour
5. ✅ Pas de conflits avec `main`

### Créer une Pull Request

1. **Titre clair** : Décrire brièvement les changements
   ```
   feat: ajouter système de notifications push
   ```

2. **Description détaillée** :
   - Quoi : Ce qui a été fait
   - Pourquoi : Raison des changements
   - Comment : Approche technique (si pertinent)
   - Tests : Comment tester

3. **Labels appropriés** :
   - `enhancement` : Nouvelle fonctionnalité
   - `bug` : Correction de bug
   - `documentation` : Documentation
   - `refactoring` : Refactoring

4. **Référencer les issues** :
   ```
   Fixes #123
   Closes #456
   ```

### Review process

1. **Automatique** : CI/CD vérifie le code
2. **Manuel** : Au moins un reviewer doit approuver
3. **Feedback** : Adresser tous les commentaires
4. **Merge** : Après approbation et tests passés

## 🧪 Tests

### Types de tests

1. **Unit tests** : Tester les use cases, repositories
2. **Widget tests** : Tester les widgets UI
3. **Integration tests** : Tester les flux complets

### Structure des tests

```dart
// test/domain/usecases/auth/sign_in_usecase_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignInUseCase', () {
    test('should return user when credentials are valid', () async {
      // Arrange
      // Act
      // Assert
    });
  });
}
```

### Exécuter les tests

```bash
# Tous les tests
flutter test

# Tests spécifiques
flutter test test/domain/usecases/auth/sign_in_usecase_test.dart

# Avec couverture
flutter test --coverage
```

## 📚 Documentation

### Code documentation

- Documenter les classes publiques
- Expliquer les paramètres complexes
- Donner des exemples si nécessaire

```dart
/// Repository d'authentification
/// 
/// Définit le contrat pour l'authentification des utilisateurs.
/// L'implémentation sera dans la couche data.
abstract class AuthRepository {
  /// Connexion avec email et mot de passe
  /// 
  /// Retourne l'utilisateur connecté ou une Failure en cas d'erreur.
  Future<Result<User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
}
```

### Documentation externe

- Mettre à jour le README si nécessaire
- Ajouter des exemples dans la documentation
- Documenter les breaking changes

## 🎯 Checklist avant de contribuer

- [ ] J'ai lu et compris le code de conduite
- [ ] J'ai vérifié qu'il n'existe pas déjà une issue/PR similaire
- [ ] Mon code suit les standards du projet
- [ ] J'ai ajouté des tests pour mes changements
- [ ] J'ai mis à jour la documentation si nécessaire
- [ ] Mon code compile sans erreurs
- [ ] Les tests passent
- [ ] Le linter ne signale pas d'erreurs
- [ ] J'ai formaté mon code avec `dart format`

## 💡 Conseils

### Pour les débutants

- Commencez par des issues marquées "good first issue"
- N'hésitez pas à poser des questions
- Demandez de l'aide si vous êtes bloqué

### Pour les contributeurs expérimentés

- Aidez les nouveaux contributeurs
- Review les PRs des autres
- Proposez des améliorations

## 📞 Besoin d'aide ?

- Ouvrir une issue avec le label "question"
- Consulter la documentation dans `/docs`
- Contacter les mainteneurs

## 🙏 Remerciements

Merci de contribuer à ce projet ! Chaque contribution, grande ou petite, est appréciée.

---

**Ensemble, construisons une plateforme qui sert la communauté chrétienne !** 🙏

