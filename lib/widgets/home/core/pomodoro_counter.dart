import 'package:flutter/material.dart';
import 'package:focal/models/timer_state.dart';

class PomodoroCounter extends StatelessWidget {
  final int total;
  final int current;
  final TimerType currentType;
  final bool isStarted;

  const PomodoroCounter({
    super.key,
    required this.total,
    required this.current,
    required this.currentType,
    required this.isStarted,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).colorScheme.secondary;
    final inactiveColor = Theme.of(context).disabledColor.withAlpha(20);
    final isWorking = currentType == TimerType.work;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isCurrentWorkingDot =
            isWorking && index == current + 1 && isStarted;
        final isActiveDot = index <= current;

        Widget dot = Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActiveDot ? activeColor : inactiveColor,
            boxShadow: isActiveDot
                ? [
                    BoxShadow(
                      color: activeColor.withAlpha(102),
                      blurRadius: 0.4,
                      spreadRadius: 0.1,
                    ),
                  ]
                : [],
          ),
        );

        if (isCurrentWorkingDot && isStarted) {
          // Apply Blinking/Pulsing animation only to the currently active dot during work time
          return BlinkingDot(color: activeColor, size: 13);
        } else {
          return dot;
        }
      }),
    );
  }
}

class BlinkingDot extends StatefulWidget {
  final Color color;
  final double size;

  const BlinkingDot({super.key, required this.color, this.size = 12});

  @override
  State<BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _opacity = Tween(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 3),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
