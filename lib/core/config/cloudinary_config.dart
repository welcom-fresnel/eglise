/// Configuration Cloudinary
///
/// Stocke les credentials Cloudinary.
///
/// ⚠️ IMPORTANT : Ne jamais commiter les vraies clés dans Git !
/// Utilisez des variables d'environnement ou un fichier .env
class CloudinaryConfig {
  CloudinaryConfig._(); // Constructeur privé

  // TODO: Remplacer par vos vraies clés Cloudinary
  // Obtenez-les sur https://cloudinary.com/console
  static const String cloudName = 'dmtzh6pyf';
  static const String apiKey = '152384216813444';
  static const String apiSecret = 'eD2Y_DgvzSIkKX4kmCBwlNxSuqk';

  // Upload preset (optionnel, pour uploads non signés)
  static const String uploadPreset = 'YOUR_UPLOAD_PRESET';

  // Configuration par défaut
  static const bool secure = true; // HTTPS
  static const String cdnSubdomain = 'res'; // CDN subdomain
}
