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

    // RESPONSIVE WRAPPER
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
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
      ),
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
      duration: const Duration(milliseconds: 600),
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
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: _DigitHalf(digit: nextDigit, isTop: true),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _DigitHalf(digit: nextDigit, isTop: false),
              ),
              if (value < 0.5)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _DigitHalf(digit: displayDigit, isTop: false),
                ),
              if (value < 0.5)
                Align(
                  alignment: Alignment.topCenter,
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: transform..rotateX(-math.pi * value),
                    child: _DigitHalf(digit: displayDigit, isTop: true),
                  ),
                )
              else
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
    // USE THEME COLORS
    final cardColor = Theme.of(context).colorScheme.tertiaryContainer;
    final textColor = Theme.of(context).colorScheme.onTertiaryContainer;

    // Calculate a slightly darker variant for gradients/shadows based on brightness
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDark ? Colors.black : Colors.grey.shade400;

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
          decoration: BoxDecoration(color: cardColor),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isTop
                        ? [cardColor, Color.lerp(cardColor, shadowColor, 0.2)!]
                        : [Color.lerp(cardColor, shadowColor, 0.2)!, cardColor],
                  ),
                ),
              ),

              Text(
                '$digit',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: shadowColor.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),

              if (isTop)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: shadowColor.withOpacity(0.4),
                      border: Border(
                        bottom: BorderSide(
                          color: shadowColor.withOpacity(0.5),
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
                  height: 1,
                  child: Container(color: Colors.white.withOpacity(0.15)),
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
      children: [
        _buildDot(context),
        const SizedBox(height: 20),
        _buildDot(context),
      ],
    );
  }

  Widget _buildDot(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.5), // Themed Dot
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
