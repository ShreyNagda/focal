// Timer Controls (formerly _TimerControls)
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focal/models/timer_state.dart';
import 'package:focal/providers/timer_provider.dart';
import 'package:focal/screens/settings_screen.dart';
import 'package:toastification/toastification.dart';

class TimerControls extends StatelessWidget {
  final TimerState state;
  final TimerProvider provider;

  const TimerControls({super.key, required this.state, required this.provider});

  void _handleLongPress(BuildContext context, TimerType currentType) {
    if (currentType != TimerType.work) {
      showDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text(
            "Skip break",
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Do you want to skip the break and start the next work session?",
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w400),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              isDefaultAction: true,
              child: const Text("Cancel"),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await provider.skipBreak();
                navigator.pop();
              },
              isDestructiveAction: true,
              child: const Text("Yes, Skip Break"),
            ),
          ],
        ),
      );
    } else {
      final theme = Theme.of(context);

      toastification.show(
        context: context,
        title: Text('Cannot skip work sessions!'),
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.bottomCenter,
        type: ToastificationType.info,
        icon: Icon(Icons.info_outline, color: Colors.redAccent),
        backgroundColor: theme.colorScheme.onPrimary,
      );
    }
  }

  void handleReset(BuildContext context, TimerType current) {
    String type = current == TimerType.work ? "Work" : "Break";
    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(
          "Restart $type",
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Do you really want to skip the $type session?",
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w400),
        ),

        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            isDefaultAction: true,
            child: const Text("Cancel"),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              provider.resetTimer();
              Navigator.pop(context);
            },
            isDestructiveAction: true,
            child: Text("Yes, Restart $type"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRunning = state.status == TimerStatus.running;

    // if (isCompleted) {
    //   return Center(
    //     child: ConstrainedBox(
    //       constraints: const BoxConstraints(maxWidth: 400),
    //       child: SizedBox(
    //         width: double.infinity,
    //         height: 60,
    //         child: ElevatedButton.icon(
    //           onPressed: () async {
    //             await provider.startTimer();
    //           },
    //           icon: const Icon(Icons.skip_next_rounded),
    //           label: const Text(
    //             'START NEXT BLOCK',
    //             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    //           ),
    //           style: ElevatedButton.styleFrom(
    //             backgroundColor: theme.colorScheme.primary,
    //             foregroundColor: theme.colorScheme.onPrimary,
    //             elevation: 4,
    //             shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(16),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // }

    return Row(
      // mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Settings Button
        SizedBox(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            heroTag: "settings_btn",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
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

        const SizedBox(width: 20),

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
        // if (state.status != TimerStatus.initial) ...[
        const SizedBox(width: 20),
        Visibility(
          visible: state.status != TimerStatus.initial,
          replacement: SizedBox(width: 60, height: 60),
          child: SizedBox(
            width: 60,
            height: 60,
            child: FloatingActionButton(
              heroTag: "reset_btn",
              onPressed: () => handleReset(context, state.currentType),
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
        ),
      ],
      // ],
    );
  }
}
