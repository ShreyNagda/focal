import 'package:shared_preferences/shared_preferences.dart';
import '../models/timer_settings.dart';

class StorageService {
  static const String _keySettings = 'timer_settings';
  static const String _keyTargetTime = 'target_end_time';
  static const String _keyTotalDuration = 'total_duration_sec';
  static const String _keyIsRunning = 'is_running';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Settings ---
  Future<void> saveSettings(TimerSettings settings) async {
    await _prefs.setString(_keySettings, settings.toJson());
  }

  TimerSettings loadSettings() {
    final raw = _prefs.getString(_keySettings);
    if (raw == null) return TimerSettings();
    return TimerSettings.fromJson(raw);
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
}
