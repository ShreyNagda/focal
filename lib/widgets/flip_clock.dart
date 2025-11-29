import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlipClock extends StatelessWidget {
  final int seconds;

  const FlipClock({super.key, required this.seconds});

  @override
  Widget build(BuildContext context) {
    final int minutes = seconds ~/ 60;
    final int remSeconds = seconds % 60;

    final minutesTens = (minutes / 10).floor();
    final minutesOnes = minutes % 10;
    final secondsTens = (remSeconds / 10).floor();
    final secondsOnes = remSeconds % 10;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FlipDigit(digit: minutesTens),
        const SizedBox(width: 6),
        FlipDigit(digit: minutesOnes),
        const SizedBox(width: 16),
        const TimeSeparator(),
        const SizedBox(width: 16),
        FlipDigit(digit: secondsTens),
        const SizedBox(width: 6),
        FlipDigit(digit: secondsOnes),
      ],
    );
  }
}

class FlipDigit extends StatefulWidget {
  final int digit;

  const FlipDigit({super.key, required this.digit});

  @override
  State<FlipDigit> createState() => _FlipDigitState();
}

class _FlipDigitState extends State<FlipDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _currentDigit;
  late int _nextDigit;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 600,
      ), // Slightly faster for responsiveness
    );
    _currentDigit = widget.digit;
    _nextDigit = widget.digit;
  }

  @override
  void didUpdateWidget(FlipDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit != widget.digit) {
      _currentDigit = oldWidget.digit;
      _nextDigit = widget.digit;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (!_controller.isAnimating && _controller.value == 1.0) {
          _currentDigit = _nextDigit;
        }

        final displayDigit = _controller.isAnimating
            ? _currentDigit
            : _nextDigit;
        final nextDigit = _nextDigit;
        final value = _controller.value;

        Matrix4 transform = Matrix4.identity()..setEntry(3, 2, 0.006);

        return Container(
          width: 80,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(75),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 1. Static Top Half of NEXT digit (Always at Top)
              Align(
                alignment: Alignment.topCenter,
                child: _DigitHalf(digit: nextDigit, isTop: true),
              ),

              // 2. Static Bottom Half of NEXT digit (Always at Bottom)
              Align(
                alignment: Alignment.bottomCenter,
                child: _DigitHalf(digit: nextDigit, isTop: false),
              ),

              // 3. Static Bottom Half of CURRENT digit (At Bottom, covered by flap)
              if (value < 0.5)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _DigitHalf(digit: displayDigit, isTop: false),
                ),

              // 4. MOVING FLAPS
              if (value < 0.5)
                // Top Half of CURRENT digit flipping DOWN (Aligned Top)
                Align(
                  alignment: Alignment.topCenter,
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: transform..rotateX(-math.pi * value),
                    child: _DigitHalf(digit: displayDigit, isTop: true),
                  ),
                )
              else
                // Bottom Half of NEXT digit flipping DOWN (Aligned Bottom)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform(
                    alignment: Alignment.topCenter,
                    transform: transform..rotateX(-math.pi * (value - 1)),
                    child: _DigitHalf(digit: nextDigit, isTop: false),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DigitHalf extends StatelessWidget {
  final int digit;
  final bool isTop;

  const _DigitHalf({required this.digit, required this.isTop});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: isTop ? const Radius.circular(8) : Radius.zero,
        bottom: isTop ? Radius.zero : const Radius.circular(8),
      ),
      child: Align(
        alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
        heightFactor: 0.5,
        child: Container(
          width: 80,
          height: 120,
          decoration: const BoxDecoration(color: Color(0xFF2C3E50)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isTop
                        ? [const Color(0xFF2C3E50), const Color(0xFF34495E)]
                        : [const Color(0xFF34495E), const Color(0xFF2C3E50)],
                  ),
                ),
              ),

              // Text
              Text(
                '$digit',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.0, // Tight height for better vertical centering
                  shadows: [
                    Shadow(
                      color: Colors.black.withAlpha(50),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),

              // Divider / Seam Visuals
              if (isTop)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 4, // Thicker hinge for top half
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black.withAlpha(130),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1, // Subtle highlight for bottom half edge
                  child: Container(color: Colors.white.withAlpha(40)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeSeparator extends StatelessWidget {
  const TimeSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [_buildDot(), const SizedBox(height: 20), _buildDot()],
    );
  }

  Widget _buildDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white70,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withAlpha(76),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
