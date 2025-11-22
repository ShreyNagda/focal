enum TimerType { work, shortBreak, longBreak }

enum TimerStatus { initial, running, paused, completed }

class TimerState {
  final int workDuration; // in minutes
  final int shortBreakDuration;
  final int longBreakDuration;
  final int pomodorosUntilLongBreak;
  final int currentPomodoros;
  final TimerType currentType;
  final TimerStatus status;
  final int remainingSeconds;
  final DateTime? startTime;
  final bool isFlipView;

  TimerState({
    this.workDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.pomodorosUntilLongBreak = 4,
    this.currentPomodoros = 0,
    this.currentType = TimerType.work,
    this.status = TimerStatus.initial,
    this.remainingSeconds = 1500, // 25 minutes default
    this.startTime,
    this.isFlipView = true,
  });

  TimerState copyWith({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? pomodorosUntilLongBreak,
    int? currentPomodoros,
    TimerType? currentType,
    TimerStatus? status,
    int? remainingSeconds,
    DateTime? startTime,
    bool? isFlipView,
  }) {
    return TimerState(
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      pomodorosUntilLongBreak:
          pomodorosUntilLongBreak ?? this.pomodorosUntilLongBreak,
      currentPomodoros: currentPomodoros ?? this.currentPomodoros,
      currentType: currentType ?? this.currentType,
      status: status ?? this.status,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      startTime: startTime ?? this.startTime,
      isFlipView: isFlipView ?? this.isFlipView,
    );
  }

  int get totalSeconds {
    switch (currentType) {
      case TimerType.work:
        return workDuration * 60;
      case TimerType.shortBreak:
        return shortBreakDuration * 60;
      case TimerType.longBreak:
        return longBreakDuration * 60;
    }
  }

  String get typeLabel {
    switch (currentType) {
      case TimerType.work:
        return 'Focus Time';
      case TimerType.shortBreak:
        return 'Short Break';
      case TimerType.longBreak:
        return 'Long Break';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'workDuration': workDuration,
      'shortBreakDuration': shortBreakDuration,
      'longBreakDuration': longBreakDuration,
      'pomodorosUntilLongBreak': pomodorosUntilLongBreak,
      'currentPomodoros': currentPomodoros,
      'currentType': currentType.index,
      'status': status.index,
      'remainingSeconds': remainingSeconds,
      'startTime': startTime?.toIso8601String(),
      'isFlipView': isFlipView,
    };
  }

  factory TimerState.fromJson(Map<String, dynamic> json) {
    return TimerState(
      workDuration: json['workDuration'] ?? 25,
      shortBreakDuration: json['shortBreakDuration'] ?? 5,
      longBreakDuration: json['longBreakDuration'] ?? 15,
      pomodorosUntilLongBreak: json['pomodorosUntilLongBreak'] ?? 4,
      currentPomodoros: json['currentPomodoros'] ?? 0,
      currentType: TimerType.values[json['currentType'] ?? 0],
      status: TimerStatus.values[json['status'] ?? 0],
      remainingSeconds: json['remainingSeconds'] ?? 1500,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null,
      isFlipView: json['isFlipView'] ?? true,
    );
  }
}
