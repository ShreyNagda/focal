import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:focal/models/timer_state.dart';
import 'package:focal/providers/config_provider.dart';
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
  bool _isLocked = false;

  void _toggleLock() {
    setState(() {
      _isLocked = !_isLocked;
    });
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      WakelockPlus.enable();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (!kIsWeb) {
      WakelockPlus.disable();
    }
  }

  // Helper to build the lock/unlock button
  Widget _buildLockToggle(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButton(
      heroTag: "lock_btn",
      mini: true, // Always mini for a discrete look
      onPressed: _toggleLock,
      // Use the surface color for a subtle look, primary color for the icon when locked
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: _isLocked
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outline.withAlpha(51)),
      ),
      child: Icon(
        _isLocked ? Icons.lock_open_rounded : Icons.lock_outline,
        size: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Consumer2<TimerProvider, ConfigProvider>(
          builder: (context, timerProvider, configProvider, child) {
            final state = timerProvider.state;
            final timerConfig = configProvider.timerConfig;

            // --- Locked Layout (Fullscreen Timer) ---
            if (_isLocked) {
              return Stack(
                children: [
                  // Fullscreen Timer Layout
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TimerLayout(state: state),
                    ),
                  ),
                  // Unlock Button (positioned top-right for easy access)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: _buildLockToggle(context),
                  ),
                ],
              );
            }

            // --- Unlocked Layout (Original) ---
            if (isLandscape && !kIsWeb) {
              // --- LANDSCAPE LAYOUT ---
              return Padding(
                // Re-added Padding here for the unlocked landscape layout
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: TimerLayout(state: state)),
                    const SizedBox(width: 20),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TimerTypeIndicator(
                              currentType: state.currentType,
                              label: state.typeLabel,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PomodoroCounter(
                                  // Used timerConfig for consistency with Pomodoro logic
                                  total:
                                      timerConfig.workIntervalsUntilLongBreak,
                                  current: state.currentPomodoros,
                                  currentType: state.currentType,
                                  isStarted:
                                      state.status != TimerStatus.initial,
                                ),
                                SizedBox(height: 15),
                                TimerControls(
                                  state: state,
                                  provider: timerProvider,
                                ),
                                SizedBox(height: 15),
                                _buildLockToggle(context),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // --- PORTRAIT LAYOUT ---
              return Column(
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: TimerTypeIndicator(
                        currentType: state.currentType,
                        label: state.typeLabel,
                      ),
                    ),
                  ),
                  Expanded(flex: 2, child: TimerLayout(state: state)),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PomodoroCounter(
                            // Used timerConfig for consistency with Pomodoro logic
                            total: timerConfig.workIntervalsUntilLongBreak,
                            current: state.currentPomodoros,
                            currentType: state.currentType,
                            isStarted: state.status != TimerStatus.initial,
                          ),
                          SizedBox(height: 15),
                          TimerControls(state: state, provider: timerProvider),
                          SizedBox(height: 15),
                          _buildLockToggle(context),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
