import 'package:focal/models/app_config.dart';
import 'package:focal/models/timer_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyAppConfig = "app_config";
  static const String _keyTimerConfig = "timer_config";
  static const String _keyTargetTime = 'target_end_time';
  static const String _keyTotalDuration = 'total_duration_sec';
  static const String _keyIsRunning = 'is_running';
  static const String _keyHasSeenTutorial = 'has_seen_tutorial'; // New Key

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- State Persistence ---
  Future<void> saveTimerState({
    required int targetEpoch,
    required int totalSeconds,
  }) async {
    await _prefs.setInt(_keyTargetTime, targetEpoch);
    await _prefs.setInt(_keyTotalDuration, totalSeconds);
    await _prefs.setBool(_keyIsRunning, true);
  }

  Future<void> clearTimerState() async {
    await _prefs.remove(_keyTargetTime);
    await _prefs.remove(_keyTotalDuration);
    await _prefs.setBool(_keyIsRunning, false);
  }

  int? getTargetEndTime() => _prefs.getInt(_keyTargetTime);
  int? getTotalDuration() => _prefs.getInt(_keyTotalDuration);
  bool getIsRunning() => _prefs.getBool(_keyIsRunning) ?? false;

  // --- Tutorial Flag ---
  bool getHasSeenTutorial() => _prefs.getBool(_keyHasSeenTutorial) ?? false;

  Future<void> setHasSeenTutorial() async {
    await _prefs.setBool(_keyHasSeenTutorial, true);
  }

  // New methods for config based architecture
  AppConfig loadAppConfig() {
    final String currentAppConfig =
        _prefs.getString(_keyAppConfig) ?? AppConfig().toJson();

    return AppConfig.fromJson(currentAppConfig);
  }

  TimerConfig loadTimerConfig() {
    final String currentTimerConfig =
        _prefs.getString(_keyTimerConfig) ?? TimerConfig().toJson();
    return TimerConfig.fromJson(currentTimerConfig);
  }

  Future<void> saveTimerConfig(TimerConfig newConfig) async {
    await _prefs.setString(_keyTimerConfig, newConfig.toJson());
  }

  Future<void> saveAppConfig(AppConfig newConfig) async {
    await _prefs.setString(_keyAppConfig, newConfig.toJson());
  }
}
