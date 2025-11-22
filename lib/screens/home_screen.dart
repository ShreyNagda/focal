import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/timer_provider.dart';
import '../models/timer_state.dart';
import 'widgets/flip_timer.dart';
import 'widgets/circular_timer.dart';
import 'widgets/settings_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      body: SafeArea(
        child: Consumer<TimerProvider>(
          builder: (context, timerProvider, child) {
            final state = timerProvider.state;

            return Column(
              children: [
                // 1. Header
                _HomeHeader(isFlipView: state.isFlipView),

                const SizedBox(height: 20),

                // 2. Timer Type Indicator (The Pill)
                _TimerTypeIndicator(
                  currentType: state.currentType,
                  label: state.typeLabel,
                ),

                const SizedBox(height: 30),

                // 3. Timer Display (Flip or Circular)
                Expanded(
                  child: Center(
                    child: state.isFlipView
                        ? FlipTimer(
                            minutes: timerProvider.getMinutes(),
                            seconds: timerProvider.getSeconds(),
                          )
                        : CircularTimer(
                            remainingSeconds: state.remainingSeconds,
                            totalSeconds: state.totalSeconds,
                            timerType: state.typeLabel,
                          ),
                  ),
                ),

                // 4. Pomodoro Dots
                _PomodoroCounter(
                  total: state.pomodorosUntilLongBreak,
                  current: state.currentPomodoros,
                ),

                const SizedBox(height: 30),

                // 5. Controls (Buttons)
                _TimerControls(state: state, provider: timerProvider),

                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Extracted Widgets
// -----------------------------------------------------------------------------

class _HomeHeader extends StatelessWidget {
  final bool isFlipView;

  const _HomeHeader({required this.isFlipView});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '🍅 Focal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kColorTextPrimary,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isFlipView ? Icons.timer_outlined : Icons.flip,
                  color: kColorTextSecondary,
                ),
                onPressed: context.read<TimerProvider>().toggleView,
                tooltip: 'Switch Timer View',
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: kColorTextSecondary),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => const SettingsDialog(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerTypeIndicator extends StatelessWidget {
  final TimerType currentType;
  final String label;

  const _TimerTypeIndicator({required this.currentType, required this.label});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (currentType) {
      case TimerType.work:
        color = kColorWork;
        icon = Icons.work_outline;
        break;
      case TimerType.shortBreak:
        color = kColorShortBreak;
        icon = Icons.coffee_outlined;
        break;
      case TimerType.longBreak:
        color = kColorLongBreak;
        icon = Icons.beach_access_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color.withAlpha(130), size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color.withAlpha(130),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _PomodoroCounter extends StatelessWidget {
  final int total;
  final int current;

  const _PomodoroCounter({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          total,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < current ? kColorWork : kColorTextMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerControls extends StatelessWidget {
  final TimerState state;
  final TimerProvider provider;

  const _TimerControls({required this.state, required this.provider});

  @override
  Widget build(BuildContext context) {
    // Dynamic Color Logic
    Color modeColor;
    switch (state.currentType) {
      case TimerType.work:
        modeColor = kColorWork.withAlpha(100);
        break;
      case TimerType.shortBreak:
        modeColor = kColorShortBreak.withAlpha(100);
        break;
      case TimerType.longBreak:
        modeColor = kColorLongBreak.withAlpha(100);
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          if (state.status == TimerStatus.completed)
            _NextBlockButton(
              onPressed: () async {
                await provider.startNextBlock();
                await provider.startTimer();
              },
              color: kColorLongBreak,
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MainControlButton(
                  label: state.status == TimerStatus.running
                      ? 'Pause'
                      : 'Start',
                  icon: state.status == TimerStatus.running
                      ? Icons.pause
                      : Icons.play_arrow,
                  onPressed: state.status == TimerStatus.running
                      ? provider.pauseTimer
                      : provider.startTimer,
                  color: modeColor,
                ),
                const SizedBox(width: 20),
                if (state.status != TimerStatus.initial)
                  _SecondaryButton(
                    label: 'Reset',
                    icon: Icons.refresh,
                    onPressed: provider.resetTimer,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

// --- Helper Buttons ---

class _MainControlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _MainControlButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white.withAlpha(150),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _NextBlockButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;

  const _NextBlockButton({required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.skip_next, size: 28),
      label: const Text(
        'Start Next Block',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white.withAlpha(100),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: kColorTextSecondary,
        side: const BorderSide(color: kColorTextMuted, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Icon(icon, size: 28),
    );
  }
}
