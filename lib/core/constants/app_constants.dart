/// Constantes globales de l'application
/// 
/// Centralise toutes les constantes pour faciliter la maintenance
/// et éviter les valeurs magiques dans le code.
class AppConstants {
  AppConstants._(); // Constructeur privé pour empêcher l'instanciation

  // Configuration Firebase
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String commentsCollection = 'comments';
  static const String groupsCollection = 'groups';
  static const String reportsCollection = 'reports';
  static const String notificationsCollection = 'notifications';
  
  // Storage paths
  static const String profilePicturesPath = 'profile_pictures';
  static const String postImagesPath = 'post_images';
  
  // Limites et pagination
  static const int postsPerPage = 20;
  static const int commentsPerPage = 50;
  static const int maxImageSizeMB = 10;
  static const int maxBioLength = 500;
  static const int maxPostLength = 5000;
  
  // Rôles utilisateurs
  static const String roleUser = 'user';
  static const String roleModerator = 'moderator';
  static const String roleAdmin = 'admin';
  
  // Types de contenu
  static const String postTypeText = 'text';
  static const String postTypeImage = 'image';
  static const String postTypeBibleVerse = 'bible_verse';
  
  // Types de notifications
  static const String notificationTypeComment = 'comment';
  static const String notificationTypeLike = 'like';
  static const String notificationTypeFollow = 'follow';
  static const String notificationTypeGroupInvite = 'group_invite';
}

