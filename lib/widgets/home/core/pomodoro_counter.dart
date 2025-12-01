import 'package:flutter/material.dart';
import 'package:focal/models/timer_state.dart';

class PomodoroCounter extends StatelessWidget {
  final int total;
  final int current;
  final TimerType currentType;

  const PomodoroCounter({
    super.key,
    required this.total,
    required this.current,
    required this.currentType,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).colorScheme.primary;
    final inactiveColor = Theme.of(context).disabledColor.withAlpha(51);
    final isWorking = currentType == TimerType.work && current > 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isCurrentWorkingDot = isWorking && index == current - 1;
        final isActiveDot = index < current;

        Widget dot = AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActiveDot ? activeColor : inactiveColor,
            boxShadow: isActiveDot
                ? [
                    BoxShadow(
                      color: activeColor.withAlpha(102),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
        );

        if (isCurrentWorkingDot) {
          // Apply Blinking/Pulsing animation only to the currently active dot during work time
          return TweenAnimationBuilder<double>(
            // Cycle opacity between fully visible and slightly dimmed
            tween: Tween(begin: 1.0, end: 0.3),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            builder: (context, opacity, child) {
              return Opacity(opacity: opacity, child: dot);
            },
            // CRITICAL: Force a rebuild to restart the Tween, creating a looping blink
            onEnd: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                (context as Element).markNeedsBuild();
              });
            },
          );
        }

        return dot;
      }),
    );
  }
}
