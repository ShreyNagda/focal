// lib/screens/widgets/settings_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/timer_provider.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late int workDuration;
  late int shortBreakDuration;
  late int longBreakDuration;
  late int pomodorosUntilLongBreak;

  @override
  void initState() {
    super.initState();
    _loadCurrentState();
  }

  void _loadCurrentState() {
    final state = context.read<TimerProvider>().state;
    setState(() {
      workDuration = state.workDuration;
      shortBreakDuration = state.shortBreakDuration;
      longBreakDuration = state.longBreakDuration;
      pomodorosUntilLongBreak = state.pomodorosUntilLongBreak;
    });
  }

  void _resetToDefaults() {
    setState(() {
      workDuration = 25;
      shortBreakDuration = 5;
      longBreakDuration = 15;
      pomodorosUntilLongBreak = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF16213E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      // Reset Defaults Button (UX Improvement)
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.white54),
                        tooltip: 'Reset Defaults',
                        onPressed: _resetToDefaults,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 32),

              // Work Duration
              _buildStepperSetting(
                'Work Duration',
                workDuration,
                (value) => setState(() => workDuration = value),
                min: 10,
                max: 120,
                color: Colors.redAccent,
                icon: Icons.work_outline,
              ),

              const SizedBox(height: 24),

              // Short Break Duration
              _buildStepperSetting(
                'Short Break',
                shortBreakDuration,
                (value) => setState(() => shortBreakDuration = value),
                min: 1,
                max: 30,
                color: Colors.greenAccent,
                icon: Icons.coffee_outlined,
              ),

              const SizedBox(height: 24),

              // Long Break Duration
              _buildStepperSetting(
                'Long Break',
                longBreakDuration,
                (value) => setState(() => longBreakDuration = value),
                min: 5,
                max: 60,
                color: Colors.blueAccent,
                icon: Icons.beach_access_outlined,
              ),

              const SizedBox(height: 24),

              // Pomodoros until long break
              _buildStepperSetting(
                'Long Break After',
                pomodorosUntilLongBreak,
                (value) => setState(() => pomodorosUntilLongBreak = value),
                min: 2,
                max: 10,
                color: Colors.purpleAccent,
                icon: Icons.repeat,
                unit: 'sets',
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<TimerProvider>().updateSettings(
                      workDuration: workDuration,
                      shortBreakDuration: shortBreakDuration,
                      longBreakDuration: longBreakDuration,
                      pomodorosUntilLongBreak: pomodorosUntilLongBreak,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepperSetting(
    String label,
    int value,
    Function(int) onChanged, {
    required int min,
    required int max,
    required Color color,
    required IconData icon,
    String unit = 'min',
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // The Custom Stepper Control
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Decrease Button
              _buildStepButton(
                icon: Icons.remove,
                onPressed: value > min ? () => onChanged(value - 1) : null,
                color: color,
              ),

              // Value Display
              SizedBox(
                width: 100,
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$value ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        TextSpan(
                          text: unit,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Increase Button
              _buildStepButton(
                icon: Icons.add,
                onPressed: value < max ? () => onChanged(value + 1) : null,
                color: color,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    final isDisabled = onPressed == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDisabled ? Colors.transparent : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDisabled ? Colors.white12 : color,
            size: 24,
          ),
        ),
      ),
    );
  }
}
