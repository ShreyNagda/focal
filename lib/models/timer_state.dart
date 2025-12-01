// --- Enums ---
enum TimerType { work, shortBreak, longBreak }

enum TimerStatus { initial, running, paused, completed }

// --- Timer State ---
class TimerState {
  final int remainingSeconds;
  final int totalSeconds;
  final TimerType currentType;
  final TimerStatus status;
  final int currentPomodoros;
  final int pomodorosUntilLongBreak;
  final bool isFlipView; // ADDED: View style flag for the UI

  const TimerState({
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.currentType,
    required this.status,
    required this.currentPomodoros,
    required this.pomodorosUntilLongBreak,
    required this.isFlipView, // ADDED
  });

  factory TimerState.initial(
    int workMinutes,
    int intervals,
    bool initialIsFlipView,
  ) {
    return TimerState(
      remainingSeconds: workMinutes * 60,
      totalSeconds: workMinutes * 60,
      currentType: TimerType.work,
      status: TimerStatus.initial,
      currentPomodoros: 0,
      pomodorosUntilLongBreak: intervals,
      isFlipView: initialIsFlipView, // Initial value from settings
    );
  }

  TimerState copyWith({
    int? remainingSeconds,
    int? totalSeconds,
    TimerType? currentType,
    TimerStatus? status,
    int? currentPomodoros,
    int? pomodorosUntilLongBreak,
    bool? isFlipView, // ADDED to copyWith
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      currentType: currentType ?? this.currentType,
      status: status ?? this.status,
      currentPomodoros: currentPomodoros ?? this.currentPomodoros,
      pomodorosUntilLongBreak:
          pomodorosUntilLongBreak ?? this.pomodorosUntilLongBreak,
      isFlipView: isFlipView ?? this.isFlipView, // Update isFlipView
    );
  }

  String get typeLabel {
    switch (currentType) {
      case TimerType.work:
        return 'Focus';
      case TimerType.shortBreak:
      case TimerType.longBreak:
        return 'Break';
    }
  }
}
