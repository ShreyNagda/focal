import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../constants/colors.dart';

class CircularTimer extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final String timerType;

  const CircularTimer({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.timerType,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;
    final minutes = (remainingSeconds / 60).floor();
    final seconds = remainingSeconds % 60;
    final timeText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Determine color based on progress
    final Color currentColor = _getColorForProgress(progress);

    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: currentColor.withAlpha(20),
                  blurRadius: 20,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),

          // Progress circle
          CustomPaint(
            size: const Size(280, 280),
            painter: CircularProgressPainter(
              progress: progress,
              color: currentColor,
            ),
          ),

          // Inner circle with time
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [kColorCircleInner, kColorCircleInnerGradient],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: kColorTextPrimary,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(color: currentColor.withAlpha(40), blurRadius: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 18,
                    color: kColorTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForProgress(double progress) {
    // UPDATE: If progress is 0 (Completed), return the initial color
    if (progress <= 0.0) {
      return kColorShortBreak; // Or kColorWork, whichever is your 'Start' color
    }

    if (progress > 0.5) {
      return kColorShortBreak;
    } else if (progress > 0.25) {
      return kColorPrimaryAction;
    } else {
      return kColorWork;
    }
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background track
    final backgroundPaint = Paint()
      ..color = Colors.white.withAlpha(10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress Arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withAlpha(50), color, color],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // End Cap
    if (progress > 0) {
      final endAngle = startAngle + sweepAngle;
      final endX = center.dx + radius * math.cos(endAngle);
      final endY = center.dy + radius * math.sin(endAngle);

      final glowPaint = Paint()
        ..color = color.withAlpha(100)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(Offset(endX, endY), 10, glowPaint);

      final capPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(endX, endY), 8, capPaint);
    }
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
