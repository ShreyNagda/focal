// Timer Controls (formerly _TimerControls)
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focal/models/timer_state.dart';

import '../../../providers/timer_provider.dart';
import '../../settings/settings_dialog.dart';

class TimerControls extends StatelessWidget {
  final TimerState state;
  final TimerProvider provider;

  const TimerControls({super.key, required this.state, required this.provider});

  void _handleLongPress(BuildContext context, TimerType currentType) {
    if (currentType != TimerType.work) {
      showDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text("Skip break"),
          content: const Text(
            "Do you want to skip the break and start the next work session?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await provider.skipBreak();
                navigator.pop();
              },
              child: const Text("Yes, Skip Break"),
            ),
          ],
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: "Cannot skip work sessions!",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRunning = state.status == TimerStatus.running;
    final isCompleted = state.status == TimerStatus.completed;

    if (isCompleted) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () async {
                await provider.startTimer();
              },
              icon: const Icon(Icons.skip_next_rounded),
              label: const Text(
                'START NEXT BLOCK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Settings Button
        SizedBox(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            heroTag: "settings_btn",
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const SettingsDialog(),
            ),
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: theme.colorScheme.outline.withAlpha(51)),
            ),
            child: const Icon(Icons.settings_outlined, size: 28),
          ),
        ),

        const SizedBox(width: 24),

        GestureDetector(
          onLongPress: () => _handleLongPress(context, state.currentType),
          child: SizedBox(
            width: 80,
            height: 80,
            child: FloatingActionButton(
              heroTag: "play_pause_btn",
              onPressed: isRunning ? provider.pauseTimer : provider.startTimer,
              backgroundColor: isRunning
                  ? theme.colorScheme.surface
                  : theme.colorScheme.primary,
              foregroundColor: isRunning
                  ? theme.colorScheme.onSurfaceVariant
                  : theme.colorScheme.onPrimary,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 40,
              ),
            ),
          ),
        ),

        // Reset Button
        if (state.status != TimerStatus.initial) ...[
          const SizedBox(width: 24),
          SizedBox(
            width: 60,
            height: 60,
            child: FloatingActionButton(
              heroTag: "reset_btn",
              onPressed: provider.resetTimer,
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: theme.colorScheme.outline.withAlpha(51),
                ),
              ),
              child: const Icon(Icons.refresh_rounded, size: 28),
            ),
          ),
        ],
      ],
    );
  }
}
