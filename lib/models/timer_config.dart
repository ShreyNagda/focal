import 'dart:convert';

class TimerConfig {
  final int workDurationMinutes;
  final int shortBreakDurationMinutes;
  final int longBreakDurationMinutes;
  final int workIntervalsUntilLongBreak;

  const TimerConfig({
    this.workDurationMinutes = 25,
    this.shortBreakDurationMinutes = 5,
    this.longBreakDurationMinutes = 15,
    this.workIntervalsUntilLongBreak = 4,
  });

  TimerConfig copyWith({
    int? workDurationMinutes,
    int? shortBreakDurationMinutes,
    int? longBreakDurationMinutes,
    int? workIntervalsUntilLongBreak,
  }) {
    return TimerConfig(
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      shortBreakDurationMinutes:
          shortBreakDurationMinutes ?? this.shortBreakDurationMinutes,
      longBreakDurationMinutes:
          longBreakDurationMinutes ?? this.longBreakDurationMinutes,
      workIntervalsUntilLongBreak:
          workIntervalsUntilLongBreak ?? this.workIntervalsUntilLongBreak,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workDurationMinutes': workDurationMinutes,
      'shortBreakDurationMinutes': shortBreakDurationMinutes,
      'longBreakDurationMinutes': longBreakDurationMinutes,
      'workIntervalsUntilLongBreak': workIntervalsUntilLongBreak,
    };
  }

  factory TimerConfig.fromMap(Map<String, dynamic> map) {
    return TimerConfig(
      workDurationMinutes: map['workDurationMinutes'] ?? 25,
      shortBreakDurationMinutes: map['shortBreakDurationMinutes'] ?? 5,
      longBreakDurationMinutes: map['longBreakDurationMinutes'] ?? 15,
      workIntervalsUntilLongBreak: map['workIntervalsUntilLongBreak'] ?? 4,
    );
  }

  String toJson() => json.encode(toMap());

  factory TimerConfig.fromJson(String source) =>
      TimerConfig.fromMap(json.decode(source));
}
