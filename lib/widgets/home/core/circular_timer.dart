import 'package:flutter/material.dart';
import 'package:focal/models/timer_state.dart';

class CircularTimer extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final TimerType timerType; // Changed from String to Enum

  const CircularTimer({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.timerType,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    double progress = totalSeconds == 0 ? 0 : remainingSeconds / totalSeconds;

    // Determine Color based on TimerType
    Color activeColor;
    String label;

    switch (timerType) {
      case TimerType.work:
        activeColor = const Color(0xFFE53935); // Red
        label = 'FOCUS';
        break;
      case TimerType.shortBreak:
        activeColor = const Color(0xFF26A69A); // Teal
        label = 'SHORT BREAK';
        break;
      case TimerType.longBreak:
        activeColor = const Color(0xFF42A5F5); // Blue
        label = 'LONG BREAK';
        break;
    }

    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Ring
          SizedBox(
            width: 300,
            height: 300,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 15,
              valueColor: const AlwaysStoppedAnimation(Colors.transparent),
            ),
          ),
          // Progress Ring
          SizedBox(
            width: 300,
            height: 300,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 15,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation(activeColor),
            ),
          ),
          // Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(remainingSeconds),
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w200,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 2.0,
                  color: theme.colorScheme.onSurface.withAlpha(75),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}
