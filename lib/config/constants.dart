class AppConstants {
  // API Keys (à remplacer par vos clés)
  static const String openWeatherApiKey = 'VOTRE_CLE_OPENWEATHER';
  static const String geminiApiKey = 'VOTRE_CLE_GEMINI';

  // API URLs
  static const String openWeatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String trainingCollection = 'training';
  static const String messagesCollection = 'messages';

  // Shared Preferences Keys
  static const String userIdKey = 'user_id';
  static const String onboardingKey = 'onboarding_complete';
  static const String locationKey = 'user_location';
}

