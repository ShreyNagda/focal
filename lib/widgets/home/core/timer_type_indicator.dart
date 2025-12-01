// Timer Type Indicator (formerly _TimerTypeIndicator)
import 'package:flutter/material.dart';
import 'package:focal/config/theme.dart';
import 'package:focal/models/timer_state.dart';

class TimerTypeIndicator extends StatelessWidget {
  final TimerType currentType;
  final String label;

  const TimerTypeIndicator({
    super.key,
    required this.currentType,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (currentType) {
      case TimerType.work:
        color = CustomColors.pomodoroRed; // Red
        icon = Icons.bolt;
        break;
      case TimerType.shortBreak:
        color = CustomColors.tealAccent; // Teal
        icon = Icons.coffee;
        break;
      case TimerType.longBreak:
        color = CustomColors.blueAccent; // Blue
        icon = Icons.weekend;
        break;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = color.withAlpha(isDark ? 38 : 25);
    final fgColor = isDark ? color : color.withAlpha(204);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withAlpha(76), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fgColor, size: 18),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: fgColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
