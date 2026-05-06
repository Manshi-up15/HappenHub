/// Central place for all app-wide constants.
class AppConstants {
  static const String baseUrl   = 'http://localhost:8080/api';

  static const String authUrl   = '$baseUrl/auth';
  static const String eventsUrl = '$baseUrl/events';
  static const String savedUrl  = '$baseUrl/saved';

  // SharedPreferences / SecureStorage keys
  static const String tokenKey     = 'jwt_token';
  static const String userIdKey    = 'user_id';
  static const String userNameKey  = 'user_name';
  static const String userEmailKey = 'user_email';
  static const String userRoleKey  = 'user_role';

  static const List<String> categories = [
    'All','Music','Food','Sports','Tech','Art','Comedy','Networking','Wellness','Education',
  ];

  static const List<String> moods = [
    'All','fun','chill','productive','romantic','adventurous',
  ];

  static const Map<String, String> moodEmoji = {
    'fun': '🎉', 'chill': '😌', 'productive': '💪',
    'romantic': '💕', 'adventurous': '🚀',
  };

  static const Map<String, String> categoryEmoji = {
    'Music': '🎵', 'Food': '🍕', 'Sports': '⚽', 'Tech': '💻',
    'Art': '🎨', 'Comedy': '😂', 'Networking': '🤝',
    'Wellness': '🧘', 'Education': '📚',
  };
}
