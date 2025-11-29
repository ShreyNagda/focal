import 'package:flutter/material.dart';

class CircularTimer extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;

  const CircularTimer({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    double progress = totalSeconds == 0 ? 0 : remainingSeconds / totalSeconds;

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
              valueColor: AlwaysStoppedAnimation(Colors.grey[900]),
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
              valueColor: const AlwaysStoppedAnimation(Color(0xFFE53935)),
            ),
          ),
          // Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(remainingSeconds),
                style: const TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                ),
              ),
              const Text(
                "FOCUS",
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 2.0,
                  color: Colors.white54,
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
