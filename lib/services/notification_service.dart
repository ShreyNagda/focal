import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:focal/constants/strings.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    if (kIsWeb) return;

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      // No onDidReceiveNotificationResponse needed for actions anymore
    );
  }

  /// Shows the sticky timer notification (No Buttons)
  static Future<void> showTimerNotification(String title, String body) async {
    if (kIsWeb) return;

    final androidDetails = AndroidNotificationDetails(
      kChannelIdTimer,
      kChannelNameTimer,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: false,
    );

    await _notifications.show(
      kNotificationId,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }

  /// Shows the completion notification
  static Future<void> showCompletionNotification(
    String title,
    String body,
  ) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      kChannelIdCompletion,
      kChannelNameCompletion,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
    );

    // We use ID 0 for completion so it doesn't conflict with ID 1
    await _notifications.show(
      kNotificationId,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> cancelTimerNotification() async {
    await _notifications.cancel(kNotificationId);
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
