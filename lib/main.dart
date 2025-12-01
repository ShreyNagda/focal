import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:focal/providers/config_provider.dart';
import 'package:focal/screens/tutorial_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'services/storage_service.dart';
import 'services/background_service.dart';
import 'services/notification_service.dart';
import 'providers/timer_provider.dart';
import 'screens/home_screen.dart';
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await NotificationService().requestNotificationPermission(); //Do not remove
    await NotificationService().initialize();
    await BackgroundService.initialize();
  }

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  // Check Tutorial Flag
  final bool showTutorial = !storageService.getHasSeenTutorial();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConfigProvider(storageService)),
        ChangeNotifierProxyProvider<ConfigProvider, TimerProvider>(
          create: (context) => TimerProvider(
            storageService,
            Provider.of<ConfigProvider>(context, listen: false),
          ),
          // Call this function whenever ConfigProvider changes
          update: (context, configProvider, timerProvider) {
            // New method in TimerProvider handles the state update logic
            timerProvider!.onConfigUpdate(
              configProvider.timerConfig,
              configProvider.appConfig,
            );
            return timerProvider;
          },
        ),
      ],
      child: ToastificationWrapper(
        child: PomodoroApp(showTutorial: showTutorial),
      ),
    ),
  );
}

class PomodoroApp extends StatelessWidget {
  final bool showTutorial;

  const PomodoroApp({super.key, required this.showTutorial});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          title: 'Focal - Pomodoro Timer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: provider.themeMode,
          // Decide Home Screen based on Flag
          home: showTutorial ? TutorialScreen() : HomeScreen(),
        );
      },
    );
  }
}
