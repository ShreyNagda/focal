import 'dart:convert';

// --- Enums ---
enum TimerType { work, shortBreak, longBreak }

enum TimerStatus { initial, running, paused, completed }

// --- Timer Settings ---
class TimerSettings {
  int workDurationMinutes;
  int shortBreakDurationMinutes;
  int longBreakDurationMinutes;
  int workIntervalsUntilLongBreak;
  bool isFlipStyle;
  bool isSoundEnabled;

  TimerSettings({
    this.workDurationMinutes = 25,
    this.shortBreakDurationMinutes = 5,
    this.longBreakDurationMinutes = 15,
    this.workIntervalsUntilLongBreak = 4,
    this.isFlipStyle = true,
    this.isSoundEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'workDurationMinutes': workDurationMinutes,
      'shortBreakDurationMinutes': shortBreakDurationMinutes,
      'longBreakDurationMinutes': longBreakDurationMinutes,
      'workIntervalsUntilLongBreak': workIntervalsUntilLongBreak,
      'isFlipStyle': isFlipStyle,
      'isSoundEnabled': isSoundEnabled,
    };
  }

  factory TimerSettings.fromMap(Map<String, dynamic> map) {
    return TimerSettings(
      workDurationMinutes: map['workDurationMinutes'] ?? 25,
      shortBreakDurationMinutes: map['shortBreakDurationMinutes'] ?? 5,
      longBreakDurationMinutes: map['longBreakDurationMinutes'] ?? 15,
      workIntervalsUntilLongBreak: map['workIntervalsUntilLongBreak'] ?? 4,
      isFlipStyle: map['isFlipStyle'] ?? true,
      isSoundEnabled: map['isFlipStyle'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory TimerSettings.fromJson(String source) =>
      TimerSettings.fromMap(json.decode(source));
}

// --- Timer State ---
class TimerState {
  final int remainingSeconds;
  final int totalSeconds;
  final TimerType currentType;
  final TimerStatus status;
  final bool isFlipView;
  final int currentPomodoros;
  final int pomodorosUntilLongBreak;
  final bool isSoundEnabled;

  const TimerState({
    required this.isSoundEnabled,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.currentType,
    required this.status,
    required this.isFlipView,
    required this.currentPomodoros,
    required this.pomodorosUntilLongBreak,
  });

  factory TimerState.initial(int workMinutes, int intervals) {
    return TimerState(
      remainingSeconds: workMinutes * 60,
      totalSeconds: workMinutes * 60,
      currentType: TimerType.work,
      status: TimerStatus.initial,
      isFlipView: true,
      currentPomodoros: 0,
      pomodorosUntilLongBreak: intervals,
      isSoundEnabled: true,
    );
  }

  TimerState copyWith({
    int? remainingSeconds,
    int? totalSeconds,
    TimerType? currentType,
    TimerStatus? status,
    bool? isFlipView,
    int? currentPomodoros,
    int? pomodorosUntilLongBreak,
    bool? isSoundEnabled,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      currentType: currentType ?? this.currentType,
      status: status ?? this.status,
      isFlipView: isFlipView ?? this.isFlipView,
      currentPomodoros: currentPomodoros ?? this.currentPomodoros,
      pomodorosUntilLongBreak:
          pomodorosUntilLongBreak ?? this.pomodorosUntilLongBreak,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
    );
  }

  String get typeLabel {
    switch (currentType) {
      case TimerType.work:
        return 'Focus';
      case TimerType.shortBreak:
        return 'Short Break';
      case TimerType.longBreak:
        return 'Long Break';
    }
  }
}
