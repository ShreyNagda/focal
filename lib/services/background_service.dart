import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/strings.dart';
import 'notification_service.dart';

class BackgroundService {
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    if (await service.isRunning()) return;

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: kChannelIdTimer,
        initialNotificationTitle: kChannelNameTimer,
        initialNotificationContent: '',
        foregroundServiceNotificationId: kNotificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onBackground: (service) => true,
      ),
    );
  }

  static Future<void> startBackgroundTimer(
    int seconds,
    String currentLabel,
    String nextLabel,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final targetTime = DateTime.now().add(Duration(seconds: seconds));

    await prefs.setInt(kKeyTargetTimestamp, targetTime.millisecondsSinceEpoch);
    await prefs.setString(kKeyCurrentLabel, currentLabel);
    await prefs.setString(kKeyNextLabel, nextLabel);

    final service = FlutterBackgroundService();
    await service.startService();
  }

  /// STOP: Called when App comes to FOREGROUND
  static Future<void> stopBackgroundTimer() async {
    final service = FlutterBackgroundService();
    service.invoke(kMethodStopService);
  }
}

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Load labels
  String currentTitle = prefs.getString(kKeyCurrentLabel) ?? "Pomodoro Timer";
  String nextBlock = prefs.getString(kKeyNextLabel) ?? "Session";

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(title: currentTitle, content: "");
  }

  service.on(kMethodStopService).listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    final targetEpoch = prefs.getInt(kKeyTargetTimestamp);
    if (targetEpoch == null) {
      timer.cancel();
      service.stopSelf();
      return;
    }

    final target = DateTime.fromMillisecondsSinceEpoch(targetEpoch);
    final now = DateTime.now();
    final remaining = target.difference(now).inSeconds;

    if (remaining >= 0) {
      if (service is AndroidServiceInstance) {
        // 1. Update Notification with Remaining Time
        service.setForegroundNotificationInfo(
          title: currentTitle,
          content: "Remaining: ${_formatTime(remaining)}",
        );
      }
    } else {
      // 2. Timer Completed
      await prefs.remove(kKeyTargetTimestamp);

      // Show Completion Notification with Next Block info
      await NotificationService.showCompletionNotification(
        "Session Complete! 🎉",
        "Up Next: $nextBlock",
      );

      service.stopSelf();
      timer.cancel();
    }
  });
}

String _formatTime(int totalSeconds) {
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
