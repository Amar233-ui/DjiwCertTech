class AppConstants {
  // API Keys (à remplacer par vos clés)
  static const String openWeatherApiKey = '735881568d383dfc3e4c93d72d226ef1';
  static const String geminiApiKey = 'AIzaSyD0Tvp9-KWkupcMXofOoEGEE017uubKId8';

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

