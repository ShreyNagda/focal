import 'package:flutter/material.dart';
import 'package:focal/models/app_config.dart';
import 'package:focal/models/timer_config.dart';
import 'package:focal/providers/config_provider.dart';
import 'package:focal/widgets/settings/settings_section.dart';
import 'package:focal/widgets/settings/timer_slider.dart';
import 'package:provider/provider.dart';
// Import TimerConfig model

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ConfigProvider>(
      builder: (context, configProvider, child) {
        final appConfig = configProvider.appConfig;
        final timerConfig = configProvider.timerConfig;

        // --- Helper for updating AppConfig fields ---
        void updateAppConfig(String field, dynamic value) {
          final newConfig = appConfig.copyWith(
            isFlipStyle: field == 'isFlipStyle' ? value : appConfig.isFlipStyle,
            themeMode: field == 'themeMode' ? value : appConfig.themeMode,
            isSoundEnabled: field == 'isSoundEnabled'
                ? value
                : appConfig.isSoundEnabled,
          );
          configProvider.updateAppConfig(newConfig);
        }

        // --- Helper for updating TimerConfig fields ---
        void updateTimerConfig(String field, int value) {
          final newConfig = timerConfig.copyWith(
            workDurationMinutes: field == 'workDuration'
                ? value
                : timerConfig.workDurationMinutes,
            shortBreakDurationMinutes: field == 'shortBreakDuration'
                ? value
                : timerConfig.shortBreakDurationMinutes,
            longBreakDurationMinutes: field == 'longBreakDuration'
                ? value
                : timerConfig.longBreakDurationMinutes,
          );
          configProvider.updateTimerConfig(newConfig);
        }

        // --- Reset Logic ---
        void resetDefaults() {
          configProvider.updateAppConfig(const AppConfig());
          configProvider.updateTimerConfig(const TimerConfig());
        }

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 500),
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: ListView(
                    padding: const EdgeInsets.all(10),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () => Navigator.pop(context),
                          label: Text("Back"),
                        ),
                      ),

                      /// ---------------- CLOCK STYLE ----------------
                      SettingsSection(
                        title: "Clock Style",
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: "flip",
                              icon: Icon(Icons.flip),
                              label: Text("Flip Clock"),
                            ),
                            ButtonSegment(
                              value: "classic",
                              icon: Icon(Icons.access_time),
                              label: Text("Classic"),
                            ),
                          ],
                          showSelectedIcon: false,
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: theme.colorScheme.primary,
                            selectedForegroundColor:
                                theme.colorScheme.onPrimary,
                          ),
                          // Use appConfig.isFlipStyle to determine selected value
                          selected: {
                            appConfig.isFlipStyle ? "flip" : "classic",
                          },
                          onSelectionChanged: (v) {
                            // Update isFlipStyle based on the selected set's first value
                            updateAppConfig('isFlipStyle', v.first == "flip");
                          },
                        ),
                      ),

                      /// ---------------- TIMER DURATIONS ----------------
                      SettingsSection(
                        title: "Timer Durations",
                        child: Column(
                          children: [
                            SliderTile(
                              title: "Focus Duration",
                              value: timerConfig.workDurationMinutes.toDouble(),
                              min:
                                  5, // Changed min from 10 to 5 to match TimerConfig in code
                              max:
                                  120, // Changed max from 60 to 120 to match TimerConfig in code
                              label: "${timerConfig.workDurationMinutes} min",
                              onChanged: (v) =>
                                  updateTimerConfig('workDuration', v.toInt()),
                            ),

                            const SizedBox(height: 12),

                            SliderTile(
                              title: "Short Break",
                              value: timerConfig.shortBreakDurationMinutes
                                  .toDouble(),
                              min: 1,
                              max:
                                  30, // Changed max from 15 to 30 to match TimerConfig in code
                              label:
                                  "${timerConfig.shortBreakDurationMinutes} min",
                              onChanged: (v) => updateTimerConfig(
                                'shortBreakDuration',
                                v.toInt(),
                              ),
                            ),

                            const SizedBox(height: 12),

                            SliderTile(
                              title: "Long Break",
                              value: timerConfig.longBreakDurationMinutes
                                  .toDouble(),
                              min:
                                  5, // Changed min from 10 to 5 to match TimerConfig in code
                              max:
                                  60, // Changed max from 30 to 60 to match TimerConfig in code
                              label:
                                  "${timerConfig.longBreakDurationMinutes} min",
                              onChanged: (v) => updateTimerConfig(
                                'longBreakDuration',
                                v.toInt(),
                              ),
                            ),

                            // The Intervals setting is missing in the slider mock-up, but it should exist.
                            // Adding a placeholder for intervals as well.
                            const SizedBox(height: 12),
                            SliderTile(
                              title: "Intervals",
                              value: timerConfig.workIntervalsUntilLongBreak
                                  .toDouble(),
                              min: 2,
                              max: 10,
                              label:
                                  "${timerConfig.workIntervalsUntilLongBreak} sets",
                              onChanged: (v) {
                                // Special handling needed if separate method is required for intervals
                                final newConfig = timerConfig.copyWith(
                                  workIntervalsUntilLongBreak: v.toInt(),
                                );
                                configProvider.updateTimerConfig(newConfig);
                              },
                            ),
                          ],
                        ),
                      ),

                      /// ---------------- THEME ----------------
                      SettingsSection(
                        title: "Theme",
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: "light",
                              icon: Icon(Icons.wb_sunny_outlined),
                              label: Text("Light"),
                            ),
                            ButtonSegment(
                              value: "dark",
                              icon: Icon(Icons.dark_mode_outlined),
                              label: Text("Dark"),
                            ),
                            ButtonSegment(
                              value: "system",
                              icon: Icon(
                                Icons.settings_brightness_rounded,
                              ), // Used rounded icon for consistency
                              label: Text("System"),
                            ),
                          ],
                          showSelectedIcon: false,
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: theme.colorScheme.primary,
                            selectedForegroundColor:
                                theme.colorScheme.onPrimary,
                          ),
                          // Use appConfig.themeMode
                          selected: {appConfig.themeMode},
                          onSelectionChanged: (v) =>
                              updateAppConfig('themeMode', v.first),
                        ),
                      ),

                      /// ---------------- SOUND ----------------
                      SettingsSection(
                        title: "Sound",
                        child: SwitchListTile(
                          value: appConfig.isSoundEnabled,
                          title: const Text("Enable Timer Sounds"),
                          onChanged: (v) =>
                              updateAppConfig('isSoundEnabled', v),
                        ),
                      ),

                      /// ---------------- RESET ----------------
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.restore),
                          label: const Text("Reset to Defaults"),
                          onPressed: () async {
                            final confirm = await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Reset Settings"),
                                content: const Text(
                                  "Are you sure you want to reset all settings?",
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text("Cancel"),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),
                                  FilledButton(
                                    child: const Text("Reset"),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) resetDefaults();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
