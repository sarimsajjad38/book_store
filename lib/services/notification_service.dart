import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    print('🔔 Background Push Notification Received: ${message.messageId}');
    print('Title: ${message.notification?.title}, Body: ${message.notification?.body}');
  }
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  static String? get fcmToken => _fcmToken;

  /// Initializes Firebase Cloud Messaging for Push Notifications
  static Future<void> initialize() async {
    try {
      // 1. Request notification permissions from user
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        print('📱 Notification Permission Status: ${settings.authorizationStatus}');
      }

      // 2. Fetch Device Registration FCM Token
      _fcmToken = await _messaging.getToken();
      if (kDebugMode) {
        print('🔑 FCM Device Token: $_fcmToken');
      }

      // 3. Listen to token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        if (kDebugMode) {
          print('🔄 FCM Token Refreshed: $newToken');
        }
      });

      // 4. Handle Foreground Messages (when app is active)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('📨 Foreground Push Notification: ${message.notification?.title}');
          print('Body: ${message.notification?.body}');
          print('Data: ${message.data}');
        }
      });

      // 5. Handle when notification opens the app
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('🚀 Notification clicked to open app: ${message.data}');
        }
      });

      // 6. Check initial message (if app was launched from terminated state via notification)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) {
          print('🎯 App opened from terminated state via notification: ${initialMessage.data}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ FCM Initialization Error (non-blocking): $e');
      }
    }
  }
}

