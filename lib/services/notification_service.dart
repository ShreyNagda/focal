import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'pomodoro_timer_channel';
  static const String channelName = 'Pomodoro Timer';

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);

    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'Active Pomodoro Timer',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
      showBadge: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> showChronometerNotification(
    int targetEpochMillis,
    int durationSeconds,
    String title,
    String body,
  ) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      usesChronometer: true,
      chronometerCountDown: true,
      when: targetEpochMillis,
      showWhen: false,
      color: const Color(0xFFE53935),
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      888,
      "$title session",
      body,
      platformChannelSpecifics,
    );
  }

  // UPDATED: Now accepts title and body
  Future<void> showPausedNotification(String title, String body) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.high,
      priority: Priority.max,
      ongoing: true,
      autoCancel: false,
      usesChronometer: false, // Static time
      showWhen: true,
      color: const Color(0xFFE53935),
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      888,
      "$title session - Paused",
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> showFinishedNotification({
    required String title,
    required String body,
    bool isSoundEnabled = false,
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'pomodoro_done_channel',
      'Timer Finished',
      importance: Importance.max,
      priority: Priority.high,
      playSound: isSoundEnabled,
      enableVibration: true,
    );
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _notificationsPlugin.show(999, title, body, platformChannelSpecifics);
  }

  Future<void> cancelNotification({int id = 888}) async {
    await _notificationsPlugin.cancel(id);
  }
}
