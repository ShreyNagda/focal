import 'package:flutter/material.dart';

import '../models/app_config.dart';
import '../models/timer_config.dart';
import '../services/storage_service.dart';

class ConfigProvider with ChangeNotifier {
  final StorageService _storage;

  TimerConfig _timerConfig = const TimerConfig();
  AppConfig _appConfig = const AppConfig();

  ConfigProvider(this._storage) {
    _init();
  }

  TimerConfig get timerConfig => _timerConfig;
  AppConfig get appConfig => _appConfig;

  ThemeMode get themeMode {
    switch (_appConfig.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void _init() {
    _timerConfig = _storage.loadTimerConfig();
    _appConfig = _storage.loadAppConfig();
    notifyListeners();
  }

  void updateTimerConfig(TimerConfig newConfig) {
    _timerConfig = newConfig;
    _storage.saveTimerConfig(newConfig);
    notifyListeners();
  }

  void updateAppConfig(AppConfig newConfig) {
    _appConfig = newConfig;
    _storage.saveAppConfig(newConfig);
    notifyListeners();
  }

  /// Toggles the view style (Flip vs Standard) and updates the state immediately.
  void toggleView() {
    final newConfig = _appConfig.copyWith(isFlipStyle: !_appConfig.isFlipStyle);
    updateAppConfig(newConfig);
  }

  /// Toggles the theme mode and updates the state immediately.
  void toggleTheme(String theme) {
    final newConfig = _appConfig.copyWith(themeMode: theme);
    updateAppConfig(newConfig);
  }

  /// Toggles the sound state and updates the state immediately.
  void toggleSound(bool isSoundEnabled) {
    final newConfig = _appConfig.copyWith(isSoundEnabled: isSoundEnabled);
    updateAppConfig(newConfig);
  }

  Future<void> completeTutorial() async {
    // Ensure this calls the correct method on the storage service
    await _storage.setHasSeenTutorial();
  }
}
