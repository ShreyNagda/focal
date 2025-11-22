import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:focal/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timer_state.dart';
import '../services/notification_service.dart';
import '../services/background_service.dart';
import '../services/audio_service.dart';

class TimerProvider with ChangeNotifier, WidgetsBindingObserver {
  TimerState _state = TimerState();
  Timer? _timer;
  DateTime? _targetEndTime;

  TimerState get state => _state;

  TimerProvider() {
    WidgetsBinding.instance.addObserver(this);
    _restoreState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // --- APP BACKGROUNDED ---
      if (_state.status == TimerStatus.running) {
        // 1. Stop local timer
        _timer?.cancel();

        // 2. Start Background Service (Shows Countdown)
        final nextLabel = _getNextBlockLabel();
        BackgroundService.startBackgroundTimer(
          _state.remainingSeconds,
          _state.typeLabel,
          nextLabel,
        );
      } else if (_state.status == TimerStatus.paused) {
        // 3. NEW: Show "Paused" Notification if paused
        NotificationService.showTimerNotification(_state.typeLabel, "Paused");
      }
    } else if (state == AppLifecycleState.resumed) {
      // --- APP RESUMED ---
      // 1. Stop Background Service
      BackgroundService.stopBackgroundTimer();

      // 2. Cancel "Paused" Notification (if it exists)
      NotificationService.cancelTimerNotification();

      // 3. Sync time and resume local timer
      _restoreState();
    }
  }

  String _getNextBlockLabel() {
    if (_state.currentType == TimerType.work) {
      final nextPomodoros = _state.currentPomodoros + 1;
      if (nextPomodoros >= _state.pomodorosUntilLongBreak) {
        return "Long Break";
      } else {
        return "Short Break";
      }
    } else {
      return "Focus Time";
    }
  }

  Future<void> startTimer() async {
    if (_state.status == TimerStatus.running) return;

    _targetEndTime = DateTime.now().add(
      Duration(seconds: _state.remainingSeconds),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kKeyTargetTime, _targetEndTime!.toIso8601String());

    _state = _state.copyWith(
      status: TimerStatus.running,
      startTime: DateTime.now(),
    );

    await _saveState();
    await NotificationService.cancelAll(); // Clear any existing notifications

    _startTicker();
    notifyListeners();
  }

  Future<void> pauseTimer() async {
    _timer?.cancel();
    _targetEndTime = null;

    // Ensure background service is stopped if we pause while open
    await BackgroundService.stopBackgroundTimer();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kKeyTargetTime);

    _state = _state.copyWith(status: TimerStatus.paused);
    await _saveState();
    notifyListeners();
  }

  Future<void> resetTimer() async {
    _timer?.cancel();
    _targetEndTime = null;

    await BackgroundService.stopBackgroundTimer();
    await NotificationService.cancelAll();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kKeyTargetTime);

    _state = _state.copyWith(
      status: TimerStatus.initial,
      remainingSeconds: _state.totalSeconds,
      startTime: null,
    );

    await _saveState();
    notifyListeners();
  }

  Future<void> _completeTimer() async {
    _targetEndTime = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kKeyTargetTime);

    _state = _state.copyWith(status: TimerStatus.completed);

    // Play Sound (App is Open)
    await AudioService.playBell();

    if (_state.currentType == TimerType.work) {
      _state = _state.copyWith(currentPomodoros: _state.currentPomodoros + 1);
    }

    await _saveState();
    notifyListeners();
  }

  Future<void> _restoreState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getString(kKeyTimerState);

    if (savedJson != null) {
      try {
        final stateMap = jsonDecode(savedJson);
        final loadedState = TimerState.fromJson(stateMap);

        if (loadedState.status == TimerStatus.running) {
          _state = loadedState;
          await _restoreTargetTimeAndSync();
        } else {
          _state = loadedState;
          _targetEndTime = null;
          _timer?.cancel();
          notifyListeners();
        }
      } catch (e) {
        debugPrint("Error restoring state: $e");
      }
    }
  }

  Future<void> _restoreTargetTimeAndSync() async {
    final prefs = await SharedPreferences.getInstance();
    final targetIso = prefs.getString(kKeyTargetTime);

    if (targetIso != null) {
      _targetEndTime = DateTime.parse(targetIso);
      _startTicker();
    } else {
      await pauseTimer();
    }
  }

  void _startTicker() {
    _timer?.cancel();
    _syncTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _syncTime());
  }

  void _syncTime() {
    if (_targetEndTime == null) return;
    final now = DateTime.now();
    final remaining = _targetEndTime!.difference(now).inSeconds;

    if (remaining <= 0) {
      _timer?.cancel();
      _state = _state.copyWith(remainingSeconds: 0);
      _completeTimer();
    } else {
      if (remaining != _state.remainingSeconds) {
        _state = _state.copyWith(remainingSeconds: remaining);
        notifyListeners();
      }
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kKeyTimerState, jsonEncode(_state.toJson()));
  }

  int getMinutes() => _state.remainingSeconds ~/ 60;
  int getSeconds() => _state.remainingSeconds % 60;

  Future<void> startNextBlock() async {
    TimerType nextType;
    if (_state.currentType == TimerType.work) {
      nextType = _state.currentPomodoros >= _state.pomodorosUntilLongBreak
          ? TimerType.longBreak
          : TimerType.shortBreak;
      if (nextType == TimerType.longBreak) {
        _state = _state.copyWith(currentPomodoros: 0);
      }
    } else {
      nextType = TimerType.work;
    }

    _state = _state.copyWith(
      currentType: nextType,
      status: TimerStatus.initial,
      remainingSeconds: _durationFor(nextType),
    );
    _state = _state.copyWith(remainingSeconds: _state.totalSeconds);

    await _saveState();
    notifyListeners();
  }

  int _durationFor(TimerType type) {
    switch (type) {
      case TimerType.work:
        return _state.workDuration * 60;
      case TimerType.shortBreak:
        return _state.shortBreakDuration * 60;
      case TimerType.longBreak:
        return _state.longBreakDuration * 60;
    }
  }

  void toggleView() {
    _state = _state.copyWith(isFlipView: !_state.isFlipView);
    notifyListeners();
  }

  void updateSettings({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? pomodorosUntilLongBreak,
  }) {
    _state = _state.copyWith(
      workDuration: workDuration,
      shortBreakDuration: shortBreakDuration,
      longBreakDuration: longBreakDuration,
      pomodorosUntilLongBreak: pomodorosUntilLongBreak,
    );
    if (_state.status == TimerStatus.initial) {
      _state = _state.copyWith(remainingSeconds: _state.totalSeconds);
    }
    _saveState();
    notifyListeners();
  }
}
