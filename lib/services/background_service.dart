import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // CRITICAL: Exit immediately if running on Web.
  // This prevents accessing dart:io Platform or initializing plugins not supported on Web.
  if (kIsWeb) return;

  if (Platform.isIOS) {
    DartPluginRegistrant.ensureInitialized();
  }

  final prefs = await SharedPreferences.getInstance();
  final storage = StorageService(prefs);
  final notificationService = NotificationService();
  await notificationService.initialize();

  Timer? finishTimer;

  Future<void> stopEverything() async {
    finishTimer?.cancel();
    await notificationService.cancelNotification();
    await storage.clearTimerState();
    service.stopSelf();
  }

  service.on('pause').listen((event) async {
    finishTimer?.cancel();

    // Extract dynamic pause messages
    final String title = event?['title'] ?? 'Timer Paused';
    final String body = event?['body'] ?? 'Tap to resume';

    await notificationService.showPausedNotification(title, body);

    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(title: title, content: body);
    }
  });

  service.on('start').listen((event) async {
    if (event == null) return;

    final int durationSeconds = event['duration'];
    final String title = event['title'] ?? 'Focus Session';
    final String body = event['body'] ?? 'Stay focused!';

    final String finishTitle = event['finishTitle'] ?? 'Session Complete';
    final String finishBody = event['finishBody'] ?? 'Time to take a break.';

    final bool enableSound = event['enableSound'] ?? true;

    final DateTime now = DateTime.now();
    final DateTime targetTime = now.add(Duration(seconds: durationSeconds));
    final int targetEpoch = targetTime.millisecondsSinceEpoch;

    await storage.saveTimerState(
      targetEpoch: targetEpoch,
      totalSeconds: durationSeconds,
    );

    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(title: title, content: body);
    }

    await notificationService.showChronometerNotification(
      targetEpoch,
      durationSeconds,
      title,
      body,
    );

    finishTimer?.cancel();
    finishTimer = Timer(Duration(seconds: durationSeconds), () async {
      await notificationService.showFinishedNotification(
        title: finishTitle,
        body: finishBody,
        isSoundEnabled: enableSound,
      );
      await storage.clearTimerState();
      service.stopSelf();
    });
  });

  service.on('stop').listen((event) async {
    await stopEverything();
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    // CRITICAL: Exit immediately if running on Web to avoid crashes
    if (kIsWeb) return;

    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'pomodoro_timer_channel',
        initialNotificationTitle: 'Focus Session',
        initialNotificationContent: 'Ready to focus...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
      ),
    );
  }
}
