import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/service_locator.dart' as di;
import 'presentation/routes/app_router.dart';
import 'presentation/theme/app_theme.dart';

// Firebase uniquement sur non-web
import 'firebase_init.dart' if (dart.library.html) 'firebase_init_stub.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement depuis .env
  try {
    if (kIsWeb) {
      // Sur le web, charger depuis web/.env
      await dotenv.load(fileName: 'web/.env');
    } else {
      // Sur les autres plateformes, charger depuis .env à la racine
      await dotenv.load();
    }
  } catch (e) {
    print('Erreur lors du chargement de .env: $e');
    // Continuer même si le fichier n'existe pas
  }

  // Initialiser Firebase (seulement sur les plateformes non-web)
  if (!kIsWeb) {
    await initializeFirebase();
  }

  // Initialiser le service locator (dépendances)
  await di.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Réseau Social Chrétien',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
