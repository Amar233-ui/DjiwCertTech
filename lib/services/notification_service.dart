import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Notifications autorisées');
      
      // Get FCM Token
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
      
      // Handle notification taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Message reçu en foreground: ${message.notification?.title}');
    // Afficher une notification locale ou une snackbar
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Message reçu en background: ${message.notification?.title}');
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tappée: ${message.notification?.title}');
    // Naviguer vers l'écran approprié
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
