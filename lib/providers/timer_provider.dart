import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter_background_service/flutter_background_service.dart';
import '../models/timer_settings.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';

class TimerProvider with ChangeNotifier, WidgetsBindingObserver {
  final StorageService _storage;
  final AudioService _audioService = AudioService();

  TimerSettings _settings = TimerSettings();
  late TimerState _state;
  Timer? _uiTicker;

  TimerProvider(this._storage) {
    WidgetsBinding.instance.addObserver(this);
    _state = TimerState.initial(25, 4);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only attempt to sync with background service on Mobile
    if (!kIsWeb &&
        state == AppLifecycleState.paused &&
        _state.status == TimerStatus.running) {
      _sendBackgroundStartCommand();
    }
  }

  TimerState get state => _state;
  TimerSettings get settings => _settings;

  int getMinutes() => _state.remainingSeconds ~/ 60;
  int getSeconds() => _state.remainingSeconds % 60;

  void _init() {
    _settings = _storage.loadSettings();
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
          if (savedTotal == _settings.shortBreakDurationMinutes * 60) {
            recoveredType = TimerType.shortBreak;
          } else if (savedTotal == _settings.longBreakDurationMinutes * 60) {
            recoveredType = TimerType.longBreak;
          }

          _state = _state.copyWith(
            status: TimerStatus.running,
            totalSeconds: savedTotal,
            currentType: recoveredType,
            isFlipView: _settings.isFlipStyle,
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

  void toggleView() {
    final newStyle = !_state.isFlipView;
    _state = _state.copyWith(isFlipView: newStyle);
    _settings.isFlipStyle = newStyle;
    _storage.saveSettings(_settings);
    notifyListeners();
  }

  void updateSettings(TimerSettings newSettings) {
    _settings = newSettings;
    _storage.saveSettings(newSettings);

    _state = _state.copyWith(isFlipView: newSettings.isFlipStyle);

    if (_state.status == TimerStatus.initial) {
      _resetStateToCurrentSettings();
    }
    notifyListeners();
  }

  Future<void> startTimer() async {
    if (_state.status == TimerStatus.running) return;

    final duration = _state.remainingSeconds;
    final target = DateTime.now().add(Duration(seconds: duration));

    _state = _state.copyWith(status: TimerStatus.running);
    notifyListeners();

    // WEB GUARD: Only run service logic on mobile
    if (!kIsWeb) {
      final service = FlutterBackgroundService();
      if (!await service.isRunning()) {
        await service.startService();
      }
      _sendBackgroundStartCommand();
    }

    // Local ticker runs on both Web and Mobile
    _startUiTicker(target);
  }

  void _sendBackgroundStartCommand() {
    String finishTitle = "Timer Finished";
    String finishBody = "Time's up!";

    if (_state.currentType == TimerType.work) {
      finishTitle = "Focus Complete";
      int nextPomos = _state.currentPomodoros + 1;
      if (nextPomos >= _settings.workIntervalsUntilLongBreak) {
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
      'isSoundEnabled': _settings.isSoundEnabled,
    });
  }

  void pauseTimer() {
    _uiTicker?.cancel();

    // WEB GUARD
    if (!kIsWeb) {
      FlutterBackgroundService().invoke('pause', {
        'title': '${_state.typeLabel} - Paused',
        'body': 'Tap to resume',
      });
    }

    _state = _state.copyWith(status: TimerStatus.paused);
    notifyListeners();
  }

  void resetTimer() {
    _uiTicker?.cancel();

    // WEB GUARD
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
      if (nextPomodoros >= _settings.workIntervalsUntilLongBreak) {
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
      pomodorosUntilLongBreak: _settings.workIntervalsUntilLongBreak,
      isFlipView: _settings.isFlipStyle,
    );
    notifyListeners();
  }

  int _getDurationForType(TimerType type) {
    switch (type) {
      case TimerType.work:
        return _settings.workDurationMinutes * 60;
      case TimerType.shortBreak:
        return _settings.shortBreakDurationMinutes * 60;
      case TimerType.longBreak:
        return _settings.longBreakDurationMinutes * 60;
    }
  }

  void _resetStateToCurrentSettings() {
    final workSecs = _settings.workDurationMinutes * 60;
    _state =
        TimerState.initial(
          _settings.workDurationMinutes,
          _settings.workIntervalsUntilLongBreak,
        ).copyWith(
          isFlipView: _settings.isFlipStyle,
          totalSeconds: workSecs,
          remainingSeconds: workSecs,
        );
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

  void _timerCompleted() {
    _uiTicker?.cancel();
    _state = _state.copyWith(
      remainingSeconds: 0,
      status: TimerStatus.completed,
    );

    if (_settings.isSoundEnabled) {
      _audioService.playBell();
    }

    notifyListeners();
  }
}
