import 'package:flutter/material.dart';
import 'package:focal/widgets/home/core/flip_clock.dart';
import 'package:provider/provider.dart';
import '../../providers/config_provider.dart';
import '../../models/timer_state.dart'; // For TimerState and TimerType definitions
import 'core/circular_timer.dart'; // Assumed core widget path

class TimerLayout extends StatelessWidget {
  final TimerState state;

  // Removed isFlipView property
  const TimerLayout({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Look up isFlipView directly from ConfigProvider
    final isFlipView = context.watch<ConfigProvider>().appConfig.isFlipStyle;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isFlipView) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FlipClock(seconds: state.remainingSeconds),
              ),
            ),
          );
        } else {
          final minSide = constraints.biggest.shortestSide;
          return Center(
            child: SizedBox(
              width: minSide,
              height: minSide,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: CircularTimer(
                      remainingSeconds: state.remainingSeconds,
                      totalSeconds: state.totalSeconds,
                      timerType: state.currentType,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
