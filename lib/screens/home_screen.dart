import 'package:flutter/material.dart';
import 'package:focal/widgets/flip_clock.dart';
import 'package:provider/provider.dart';
import '../models/timer_settings.dart';
import '../providers/timer_provider.dart';
import '../widgets/circular_timer.dart';
import '../widgets/settings_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // kColorBackground
      body: SafeArea(
        child: Consumer<TimerProvider>(
          builder: (context, timerProvider, child) {
            final state = timerProvider.state;

            return Column(
              children: [
                // 1. Header
                _HomeHeader(),

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
                        ? FlipClock(
                            seconds:
                                timerProvider.getSeconds() +
                                timerProvider.getMinutes() * 60,
                          )
                        : CircularTimer(
                            remainingSeconds: state.remainingSeconds,
                            totalSeconds: state.totalSeconds,
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

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
              color: Colors.white, // kColorTextPrimary
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white54,
            ), // kColorTextSecondary
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const SettingsDialog(),
            ),
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
        color = const Color(0xFFE53935); // kColorWork
        icon = Icons.work_outline;
        break;
      case TimerType.shortBreak:
        color = const Color(0xFF26A69A); // kColorShortBreak
        icon = Icons.coffee_outlined;
        break;
      case TimerType.longBreak:
        color = const Color(0xFF42A5F5); // kColorLongBreak
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
                color: index < current
                    ? const Color(0xFFE53935) // kColorWork
                    : Colors.white24, // kColorTextMuted
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
        modeColor = const Color(0xFFE53935).withAlpha(100); // kColorWork
        break;
      case TimerType.shortBreak:
        modeColor = const Color(0xFF26A69A).withAlpha(100); // kColorShortBreak
        break;
      case TimerType.longBreak:
        modeColor = const Color(0xFF42A5F5).withAlpha(100); // kColorLongBreak
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
                provider.startTimer();
              },
              color: const Color(0xFF42A5F5), // kColorLongBreak
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MainControlButton(
                  label: state.status == TimerStatus.running
                      ? 'Pause'
                      : state.status == TimerStatus.paused
                      ? "Resume"
                      : "Start",
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
        foregroundColor: Colors.white.withAlpha(250),
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
        foregroundColor: Colors.white54, // kColorTextSecondary
        side: const BorderSide(
          color: Colors.white24,
          width: 2,
        ), // kColorTextMuted
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Icon(icon, size: 28),
    );
  }
}
