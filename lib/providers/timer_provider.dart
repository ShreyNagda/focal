import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:focal/services/notification_service.dart';
import '../models/timer_config.dart'; // NEW IMPORT
import '../models/app_config.dart'; // NEW IMPORT
import '../models/timer_state.dart'; // NEW IMPORT for enums/state
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../providers/config_provider.dart'; // ADDED IMPORT

// Assuming TimerType and TimerStatus enums are now in timer_state.dart
// and TimerState is also in that file.

class TimerProvider with ChangeNotifier, WidgetsBindingObserver {
  final StorageService _storage;
  final ConfigProvider _configProvider; // ADDED DEPENDENCY

  TimerConfig _timerConfig = const TimerConfig(); // Replaced _settings
  AppConfig _appConfig = const AppConfig(); // NEW config for view/theme/sound
  late TimerState _state;
  Timer? _uiTicker;

  // MODIFIED CONSTRUCTOR: Now requires ConfigProvider
  TimerProvider(this._storage, this._configProvider) {
    WidgetsBinding.instance.addObserver(this);

    // Initialize config from ConfigProvider at creation time
    _timerConfig = _configProvider.timerConfig;
    _appConfig = _configProvider.appConfig;

    // Use initial values from TimerConfig for TimerState setup
    _state = TimerState.initial(
      _timerConfig.workDurationMinutes,
      _timerConfig.workIntervalsUntilLongBreak,
      _appConfig.isFlipStyle,
    );
    _init();
  }

  // NEW METHOD: Handles updates received from ConfigProvider
  void onConfigUpdate(TimerConfig newTimerConfig, AppConfig newAppConfig) {
    // Check if any core duration settings have changed
    final bool timerConfigChanged =
        _timerConfig.workDurationMinutes !=
            newTimerConfig.workDurationMinutes ||
        _timerConfig.shortBreakDurationMinutes !=
            newTimerConfig.shortBreakDurationMinutes ||
        _timerConfig.longBreakDurationMinutes !=
            newTimerConfig.longBreakDurationMinutes ||
        _timerConfig.workIntervalsUntilLongBreak !=
            newTimerConfig.workIntervalsUntilLongBreak;

    // Check if any App config settings have changed (for theme/sound/view)
    final bool appConfigChanged =
        _appConfig.themeMode != newAppConfig.themeMode ||
        _appConfig.isFlipStyle != newAppConfig.isFlipStyle ||
        _appConfig.isSoundEnabled != newAppConfig.isSoundEnabled;

    // Update internal configurations
    _timerConfig = newTimerConfig;
    _appConfig = newAppConfig;

    // FIX: If TimerConfig changed AND the timer is in the initial state,
    // update the displayed duration immediately.
    if (timerConfigChanged && _state.status == TimerStatus.initial) {
      _resetStateToCurrentSettings();
    }
    // Also notify listeners if AppConfig changed (e.g., theme mode for PomodoroApp, flip view)
    else if (appConfigChanged) {
      notifyListeners();
    }
  }

  // --- Theme Helper ---
  ThemeMode get themeMode {
    switch (_appConfig.themeMode) {
      // Use _appConfig
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!kIsWeb &&
        state == AppLifecycleState.paused &&
        _state.status == TimerStatus.running) {
      _sendBackgroundStartCommand();
    }
  }

  TimerState get state => _state;
  TimerConfig get timerConfig => _timerConfig; // New getter
  AppConfig get appConfig => _appConfig; // New getter

  int getMinutes() => _state.remainingSeconds ~/ 60;
  int getSeconds() => _state.remainingSeconds % 60;

  void _init() {
    // Load both configs (assuming StorageService is updated)
    _timerConfig = _storage.loadTimerConfig();
    _appConfig = _storage.loadAppConfig();

    _resetStateToCurrentSettings();

    if (_storage.getIsRunning()) {
      final int? targetEpoch = _storage.getTargetEndTime();
      final int? savedTotal = _storage.getTotalDuration();

      if (targetEpoch != null && savedTotal != null) {
        final DateTime target = DateTime.fromMillisecondsSinceEpoch(
          targetEpoch,
        );
        final DateTime now = DateTime.now();

        if (target.isAfter(now)) {
          TimerType recoveredType = TimerType.work;
          if (savedTotal == _timerConfig.shortBreakDurationMinutes * 60) {
            recoveredType = TimerType.shortBreak;
          } else if (savedTotal == _timerConfig.longBreakDurationMinutes * 60) {
            recoveredType = TimerType.longBreak;
          }

          _state = _state.copyWith(
            status: TimerStatus.running,
            totalSeconds: savedTotal,
            currentType: recoveredType,
            // Flip view setting comes from AppConfig
          );

          _startUiTicker(target);
        } else {
          _timerCompleted();
          _storage.clearTimerState();
        }
      }
    }
    notifyListeners();
  }

  // REMOVED: toggleView, updateTimerConfig, and updateAppConfig
  // These functions are now handled by ConfigProvider and onConfigUpdate

  Future<void> startTimer() async {
    if (_state.status == TimerStatus.running) return;

    final duration = _state.remainingSeconds;
    final target = DateTime.now().add(Duration(seconds: duration));

    _state = _state.copyWith(status: TimerStatus.running);
    notifyListeners();
    NotificationService().cancelNotification(id: 999);
    if (!kIsWeb) {
      final service = FlutterBackgroundService();
      if (!await service.isRunning()) {
        await service.startService();
      }
      _sendBackgroundStartCommand();
    }

    _startUiTicker(target);
  }

  void _sendBackgroundStartCommand() {
    String finishTitle = "Timer Finished";
    String finishBody = "Time's up!";

    if (_state.currentType == TimerType.work) {
      finishTitle = "Focus Complete";
      int nextPomos = _state.currentPomodoros + 1;
      if (nextPomos >= _timerConfig.workIntervalsUntilLongBreak) {
        // Use _timerConfig
        finishBody = "Great job! Time for a long break.";
      } else {
        finishBody = "Good work. Take a short break.";
      }
    } else {
      finishTitle = "Break Over";
      finishBody = "Ready to focus again?";
    }

    FlutterBackgroundService().invoke('start', {
      'duration': _state.remainingSeconds,
      'title': _state.typeLabel,
      'body': _state.currentType == TimerType.work
          ? 'Stay focused!'
          : 'Relax & recharge.',
      'finishTitle': finishTitle,
      'finishBody': finishBody,
      'enableSound': _appConfig.isSoundEnabled, // Use _appConfig
    });
  }

  void pauseTimer() {
    _uiTicker?.cancel();

    if (!kIsWeb) {
      FlutterBackgroundService().invoke('pause', {
        'title': '${_state.typeLabel} session - Paused',
        'body': 'Tap to resume',
      });
    }

    _state = _state.copyWith(status: TimerStatus.paused);
    notifyListeners();
  }

  Future<void> skipBreak() async {
    if (_state.currentType != TimerType.work) {
      // 1. Stop all current ticking and background services
      _uiTicker?.cancel();
      if (!kIsWeb) {
        FlutterBackgroundService().invoke('stop');
      }
      // 2. Clear storage and transition to the next block (which will be 'work')
      await _storage.clearTimerState();
      await startNextBlock();
    }
  }

  void resetTimer() {
    _uiTicker?.cancel();

    if (!kIsWeb) {
      FlutterBackgroundService().invoke('stop');
    }
    _storage.clearTimerState();

    int duration = _getDurationForType(_state.currentType);

    _state = _state.copyWith(
      status: TimerStatus.initial,
      remainingSeconds: duration,
      totalSeconds: duration,
    );
    notifyListeners();
  }

  Future<void> startNextBlock() async {
    TimerType nextType;
    int nextPomodoros = _state.currentPomodoros;

    if (_state.currentType == TimerType.work) {
      nextPomodoros++;
      if (nextPomodoros >= _timerConfig.workIntervalsUntilLongBreak) {
        // Use _timerConfig
        nextType = TimerType.longBreak;
      } else {
        nextType = TimerType.shortBreak;
      }
    } else if (_state.currentType == TimerType.longBreak) {
      nextType = TimerType.work;
      nextPomodoros = 0;
    } else {
      nextType = TimerType.work;
    }

    int nextDuration = _getDurationForType(nextType);

    _state = _state.copyWith(
      currentType: nextType,
      status: TimerStatus.initial,
      remainingSeconds: nextDuration,
      totalSeconds: nextDuration,
      currentPomodoros: nextPomodoros,
      pomodorosUntilLongBreak:
          _timerConfig.workIntervalsUntilLongBreak, // Use _timerConfig
      // isFlipView is no longer a state parameter
    );
    notifyListeners();
  }

  int _getDurationForType(TimerType type) {
    switch (type) {
      case TimerType.work:
        return _timerConfig.workDurationMinutes * 60; // Use _timerConfig
      case TimerType.shortBreak:
        return _timerConfig.shortBreakDurationMinutes * 60; // Use _timerConfig
      case TimerType.longBreak:
        return _timerConfig.longBreakDurationMinutes * 60; // Use _timerConfig
    }
  }

  void _resetStateToCurrentSettings() {
    final workSecs = _timerConfig.workDurationMinutes * 60; // Use _timerConfig
    _state =
        TimerState.initial(
          _timerConfig.workDurationMinutes, // Use _timerConfig
          _timerConfig.workIntervalsUntilLongBreak, // Use _timerConfig
          _appConfig.isFlipStyle,
        ).copyWith(
          // isFlipView is no longer set in state's copyWith
          totalSeconds: workSecs,
          remainingSeconds: workSecs,
        );
    notifyListeners(); // ADDED: Ensure UI updates when settings change
  }

  void _startUiTicker(DateTime targetTime) {
    _uiTicker?.cancel();
    _uiTicker = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      final now = DateTime.now();
      final diff = targetTime.difference(now).inSeconds;

      if (diff <= 0) {
        _timerCompleted();
      } else {
        _state = _state.copyWith(remainingSeconds: diff);
        notifyListeners();
      }
    });
  }

  Future<void> _timerCompleted() async {
    _uiTicker?.cancel();

    // 1. Play completion sound
    if (_appConfig.isSoundEnabled) {
      // Use _appConfig
      await AudioService().playBell();
    }

    // 2. Clear background service and storage state
    if (!kIsWeb) {
      FlutterBackgroundService().invoke('stop');
    }
    await _storage.clearTimerState();

    // 3. Automatically transition to the next block (which handles the pomodoro count update)
    // startNextBlock() sets the status to TimerStatus.initial for the next block.
    await startNextBlock();

    // Note: notifyListeners() is called inside startNextBlock()
  }

  Future<void> completeTutorial() async {
    await _storage.setHasSeenTutorial();
  }
}
