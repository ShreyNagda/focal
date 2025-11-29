import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/timer_provider.dart';
import '../../models/timer_settings.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late int _workMinutes;
  late int _shortBreakMinutes;
  late int _longBreakMinutes;
  late int _intervals;
  late bool _isFlip;
  late bool _enableSound;

  @override
  void initState() {
    super.initState();
    _loadCurrentState();
  }

  void _loadCurrentState() {
    final settings = context.read<TimerProvider>().settings;
    setState(() {
      _workMinutes = settings.workDurationMinutes;
      _shortBreakMinutes = settings.shortBreakDurationMinutes;
      _longBreakMinutes = settings.longBreakDurationMinutes;
      _intervals = settings.workIntervalsUntilLongBreak;
      _isFlip = settings.isFlipStyle;
      _enableSound = settings.isSoundEnabled;
    });
  }

  void _resetToDefaults() {
    setState(() {
      _workMinutes = 25;
      _shortBreakMinutes = 5;
      _longBreakMinutes = 15;
      _intervals = 4;
      _isFlip = true;
      _enableSound = true;
    });
  }

  void _save() {
    context.read<TimerProvider>().updateSettings(
      TimerSettings(
        workDurationMinutes: _workMinutes,
        shortBreakDurationMinutes: _shortBreakMinutes,
        longBreakDurationMinutes: _longBreakMinutes,
        workIntervalsUntilLongBreak: _intervals,
        isFlipStyle: _isFlip,
        isSoundEnabled: _enableSound,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF16213E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24), // Increased padding slightly
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24, // Increased from 20
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.restore,
                        color: Colors.white54,
                        size: 24,
                      ),
                      tooltip: 'Reset Defaults',
                      onPressed: _resetToDefaults,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 32),

            // Visual & Sound Settings
            Row(
              children: [
                Expanded(child: _buildCompactClockSelector()),
                const SizedBox(width: 16),
                _buildSoundToggle(),
              ],
            ),

            const SizedBox(height: 24),

            // Time Settings
            _buildCompactStepper(
              'Work',
              _workMinutes,
              (val) => setState(() => _workMinutes = val),
              min: 5,
              max: 120,
              color: Colors.redAccent,
              icon: Icons.work_outline,
            ),

            _buildCompactStepper(
              'Short Break',
              _shortBreakMinutes,
              (val) => setState(() => _shortBreakMinutes = val),
              min: 1,
              max: 30,
              color: Colors.greenAccent,
              icon: Icons.coffee_outlined,
            ),

            _buildCompactStepper(
              'Long Break',
              _longBreakMinutes,
              (val) => setState(() => _longBreakMinutes = val),
              min: 5,
              max: 60,
              color: Colors.blueAccent,
              icon: Icons.beach_access_outlined,
            ),

            _buildCompactStepper(
              'Intervals',
              _intervals,
              (val) => setState(() => _intervals = val),
              min: 2,
              max: 10,
              color: Colors.purpleAccent,
              icon: Icons.repeat,
              isUnitless: true,
            ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ), // Increased from 15
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactClockSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Clock Style',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ), // Increased from 12
        ),
        const SizedBox(height: 12),
        Container(
          height: 48, // Increased height for touch targets
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(13)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildCompactToggle(
                  icon: Icons.flip,
                  isSelected: _isFlip,
                  onTap: () => setState(() => _isFlip = true),
                ),
              ),
              Expanded(
                child: _buildCompactToggle(
                  icon: Icons.donut_large,
                  isSelected: !_isFlip,
                  onTap: () => setState(() => _isFlip = false),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSoundToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sound',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ), // Increased from 12
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => setState(() => _enableSound = !_enableSound),
          child: Container(
            height: 48, // Increased height
            width: 56, // Increased width
            decoration: BoxDecoration(
              color: _enableSound
                  ? Colors.deepPurple.withAlpha(50)
                  : Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _enableSound
                    ? Colors.deepPurple
                    : Colors.white.withAlpha(13),
              ),
            ),
            child: Icon(
              _enableSound ? Icons.volume_up : Icons.volume_off,
              color: _enableSound ? Colors.deepPurpleAccent : Colors.white24,
              size: 24, // Increased icon size
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactToggle({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orangeAccent.withAlpha(50)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 30, // Increased size
          color: isSelected ? Colors.orangeAccent : Colors.white24,
        ),
      ),
    );
  }

  Widget _buildCompactStepper(
    String label,
    int value,
    Function(int) onChanged, {
    required int min,
    required int max,
    required Color color,
    required IconData icon,
    bool isUnitless = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0), // Increased spacing
      child: Row(
        children: [
          _buildIconBox(icon, color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18, // Increased from 15
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            height: 42, // Increased height
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha(13)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStepBtn(
                  Icons.remove,
                  value > min ? () => onChanged(value - 1) : null,
                  color,
                ),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 48,
                  ), // Wider text area
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '$value${isUnitless ? '' : 'm'}',
                    style: TextStyle(
                      fontSize: 18, // Increased from 15
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                _buildStepBtn(
                  Icons.add,
                  value < max ? () => onChanged(value + 1) : null,
                  color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10), // Increased padding
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22), // Increased size
    );
  }

  Widget _buildStepBtn(IconData icon, VoidCallback? onTap, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 42, // Increased touch target
          height: 42,
          child: Icon(
            icon,
            size: 22, // Increased size
            color: onTap == null ? Colors.white12 : color,
          ),
        ),
      ),
    );
  }
}
