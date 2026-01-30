import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration Cloudinary
///
/// Stocke les credentials Cloudinary chargées depuis les variables d'environnement.
/// Les vraies clés ne doivent JAMAIS être en dur dans le code !
class CloudinaryConfig {
  CloudinaryConfig._(); // Constructeur privé

  /// Chargé depuis .env file
  static String get cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get apiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static String get apiSecret => dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

  /// Upload preset (optionnel, pour uploads non signés)
  static String get uploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'eglise_unsigned';

  /// Configuration par défauts
  static const bool secure = true; // HTTPS
  static const String cdnSubdomain = 'res'; // CDN subdomain
  
  /// Valide que toutes les clés requises sont chargées
  static bool isConfigured() {
    return cloudName.isNotEmpty && apiKey.isNotEmpty && apiSecret.isNotEmpty;
  }
}
