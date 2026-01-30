import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/feed_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../providers/auth_provider.dart';

/// Configuration du routage de l'application
/// 
/// Utilise go_router pour une navigation déclarative et type-safe.
class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      // Vérifier l'état d'authentification
      final container = ProviderScope.containerOf(context);
      final authState = container.read(authStateProvider);
      
      final isLoggedIn = authState.valueOrNull != null;
      final isGoingToAuth = state.matchedLocation == '/login' || 
                           state.matchedLocation == '/register';

      // Rediriger vers login si non connecté et pas déjà sur une page d'auth
      if (!isLoggedIn && !isGoingToAuth) {
        return '/login';
      }

      // Rediriger vers le feed si connecté et sur une page d'auth
      if (isLoggedIn && isGoingToAuth) {
        return '/feed';
      }

      return null; // Pas de redirection
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/feed',
        name: 'feed',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}

