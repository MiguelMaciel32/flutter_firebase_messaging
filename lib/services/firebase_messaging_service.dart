import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseMessagingService {
  // Single instance
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();

  FirebaseMessagingService._internal();

  factory FirebaseMessagingService() => _instance;

  /// Init Firebase Messaging and set up the message listeners.
  Future<void> init() async {
    _handlePushNotificationsToken();

    _requestPermission();

    // Register the background message handler (when the app is terminated)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Set up foreground message listener
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Handle notification taps when the app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Get any messages which caused the application to open from a terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null){
      _onMessageOpenedApp(initialMessage);
    }
  }

  Future<void> _handlePushNotificationsToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('Push notifications token: $token');

    //Listen to token changes
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      // If necessary send token to application server.
    }).onError((err) {
      // Handle token refresh error here.
    });
  }

  Future<void> _requestPermission() async {
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('User granted permission: ${result.authorizationStatus}');
  }

  /// Must be top-level function or static
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
    debugPrint('Background message received: ${message.data.toString()}');
  }

  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.data.toString()}');
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('Notification caused the app to open: ${message.data.toString()}');
  }
}
