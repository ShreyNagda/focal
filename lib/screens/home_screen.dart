import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../providers/timer_provider.dart';
import '../widgets/home/core/pomodoro_counter.dart';
import '../widgets/home/core/timer_controls.dart';
import '../widgets/home/core/timer_type_indicator.dart';
import '../widgets/home/timer_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Assuming WakelockPlus is added to pubspec.yaml
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    super.dispose();
    WakelockPlus.disable();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Consumer<TimerProvider>(
            builder: (context, timerProvider, child) {
              final state = timerProvider.state;

              if (isLandscape && !kIsWeb) {
                // --- LANDSCAPE LAYOUT ---
                return Row(
                  children: [
                    Expanded(flex: 1, child: TimerLayout(state: state)),
                    const SizedBox(width: 32),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TimerTypeIndicator(
                            currentType: state.currentType,
                            label: state.typeLabel,
                          ),
                          PomodoroCounter(
                            total: state.pomodorosUntilLongBreak,
                            current: state.currentPomodoros,
                            currentType: state.currentType,
                          ),
                          TimerControls(state: state, provider: timerProvider),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                // --- PORTRAIT LAYOUT ---
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: TimerTypeIndicator(
                          currentType: state.currentType,
                          label: state.typeLabel,
                        ),
                      ),
                    ),
                    Expanded(flex: 10, child: TimerLayout(state: state)),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: PomodoroCounter(
                          total: state.pomodorosUntilLongBreak,
                          current: state.currentPomodoros,
                          currentType: state.currentType,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: TimerControls(
                        state: state,
                        provider: timerProvider,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
