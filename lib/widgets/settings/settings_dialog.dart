import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focal/models/app_config.dart';
import 'package:focal/models/timer_config.dart';
import 'package:focal/providers/config_provider.dart';
import 'package:focal/screens/tutorial_screen.dart';
import 'package:provider/provider.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  // Local state variables to hold current unsaved values
  late int _workMinutes;
  late int _shortBreakMinutes;
  late int _longBreakMinutes;
  late int _intervals;
  late bool _isFlip;
  late bool _isSoundEnabled;
  late String _themeMode;

  @override
  void initState() {
    super.initState();
    _loadCurrentState();
  }

  /// Loads current settings from the ConfigProvider into local state.
  void _loadCurrentState() {
    // Read configuration from the dedicated ConfigProvider
    final config = context.read<ConfigProvider>();
    final timerConfig = config.timerConfig;
    final appConfig = config.appConfig;

    setState(() {
      // Timer Configuration
      _workMinutes = timerConfig.workDurationMinutes;
      _shortBreakMinutes = timerConfig.shortBreakDurationMinutes;
      _longBreakMinutes = timerConfig.longBreakDurationMinutes;
      _intervals = timerConfig.workIntervalsUntilLongBreak;

      // App Configuration (Visual/Sound)
      _isFlip = appConfig.isFlipStyle;
      _isSoundEnabled = appConfig.isSoundEnabled;
      _themeMode = appConfig.themeMode;
    });
  }

  /// Resets local state to default values and pushes defaults to ConfigProvider.
  void _resetToDefaults() {
    // 1. Reset local state to match model defaults
    setState(() {
      _workMinutes = const TimerConfig().workDurationMinutes; // 25
      _shortBreakMinutes = const TimerConfig().shortBreakDurationMinutes; // 5
      _longBreakMinutes = const TimerConfig().longBreakDurationMinutes; // 15
      _intervals = const TimerConfig().workIntervalsUntilLongBreak; // 4

      _isFlip = const AppConfig().isFlipStyle; // true
      _isSoundEnabled = const AppConfig().isSoundEnabled; // true
      _themeMode = const AppConfig().themeMode; // 'light'
    });

    // 2. Push default models to the provider
    final configProvider = context.read<ConfigProvider>();
    configProvider.updateTimerConfig(const TimerConfig());
    configProvider.updateAppConfig(const AppConfig());
  }

  /// Updates a visual/sound setting immediately and pushes the new AppConfig.
  void _updateRealtimeSetting({
    bool? isFlip,
    bool? isSoundEnabled,
    String? themeMode,
  }) {
    // 1. Update local state
    setState(() {
      if (isFlip != null) _isFlip = isFlip;
      if (isSoundEnabled != null) _isSoundEnabled = isSoundEnabled;
      if (themeMode != null) _themeMode = themeMode;
    });

    // 2. Create new AppConfig based on local state and push update
    final configProvider = context.read<ConfigProvider>();
    final newAppConfig = configProvider.appConfig.copyWith(
      isFlipStyle: _isFlip,
      isSoundEnabled: _isSoundEnabled,
      themeMode: _themeMode,
    );
    configProvider.updateAppConfig(newAppConfig);
  }

  /// Updates a time/interval setting immediately and pushes the new TimerConfig.
  void _updateTimeSetting({int? work, int? short, int? long, int? intervals}) {
    // 1. Update local state
    setState(() {
      if (work != null) _workMinutes = work;
      if (short != null) _shortBreakMinutes = short;
      if (long != null) _longBreakMinutes = long;
      if (intervals != null) _intervals = intervals;
    });

    // 2. Create new TimerConfig based on local state and push update
    final configProvider = context.read<ConfigProvider>();
    final newTimerConfig = configProvider.timerConfig.copyWith(
      workDurationMinutes: _workMinutes,
      shortBreakDurationMinutes: _shortBreakMinutes,
      longBreakDurationMinutes: _longBreakMinutes,
      workIntervalsUntilLongBreak: _intervals,
    );
    configProvider.updateTimerConfig(newTimerConfig);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.dialogTheme.backgroundColor;
    final textColor = theme.colorScheme.onSurface;
    final borderColor = theme.colorScheme.outline.withAlpha(50);
    // Unified color for all steppers
    final stepperColor = theme.colorScheme.primary;

    final double height = 5;

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.restore,
                          color: theme.iconTheme.color,
                          size: 20,
                        ),
                        tooltip: 'Reset Defaults',
                        onPressed: _resetToDefaults,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: theme.iconTheme.color,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(color: theme.dividerColor, height: 20),

              // Visual & Sound
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clock Style',
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor.withAlpha(180),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: height),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor, width: 1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildOptionButton(
                                  label: "Flip",
                                  icon: Icons.flip,
                                  isSelected: _isFlip,
                                  onTap: () =>
                                      _updateRealtimeSetting(isFlip: true),
                                ),
                              ),
                              Expanded(
                                child: _buildOptionButton(
                                  label: "Classic",
                                  icon: Icons.donut_large,
                                  isSelected: !_isFlip,
                                  onTap: () =>
                                      _updateRealtimeSetting(isFlip: false),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sound',
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor.withAlpha(180),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: height),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor, width: 1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: _buildOptionButton(
                            label: _isSoundEnabled ? "On" : "Off",
                            icon: _isSoundEnabled
                                ? Icons.volume_up
                                : Icons.volume_off,
                            isSelected: _isSoundEnabled,
                            onTap: () => _updateRealtimeSetting(
                              isSoundEnabled: !_isSoundEnabled,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 1.3),
              // Theme
              Text(
                'Theme',
                style: TextStyle(
                  fontSize: 16,
                  color: textColor.withAlpha(180),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: height),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildOptionButton(
                        label: "Light",
                        icon: Icons.wb_sunny_rounded,
                        isSelected: _themeMode == 'light',
                        onTap: () => _updateRealtimeSetting(themeMode: 'light'),
                      ),
                    ),
                    Expanded(
                      child: _buildOptionButton(
                        label: "Dark",
                        icon: Icons.nights_stay_rounded,
                        isSelected: _themeMode == 'dark',
                        onTap: () => _updateRealtimeSetting(themeMode: 'dark'),
                      ),
                    ),
                    Expanded(
                      child: _buildOptionButton(
                        label: "System",
                        icon: Icons.settings_brightness_rounded,
                        isSelected: _themeMode == 'system',
                        onTap: () =>
                            _updateRealtimeSetting(themeMode: 'system'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Time Settings
              _CompactStepper(
                label: 'Work',
                value: _workMinutes,
                onChanged: (v) => _updateTimeSetting(work: v),
                min: 5,
                max: 120,
                color: stepperColor,
                icon: Icons.work_outline,
                suffix: 'min',
              ),
              _CompactStepper(
                label: 'Short Break',
                value: _shortBreakMinutes,
                onChanged: (v) => _updateTimeSetting(short: v),
                min: 1,
                max: 30,
                color: stepperColor,
                icon: Icons.coffee_outlined,
                suffix: 'min',
              ),
              _CompactStepper(
                label: 'Long Break',
                value: _longBreakMinutes,
                onChanged: (v) => _updateTimeSetting(long: v),
                min: 5,
                max: 60,
                color: stepperColor,
                icon: Icons.beach_access_outlined,
                suffix: 'min',
              ),
              _CompactStepper(
                label: 'Intervals',
                value: _intervals,
                onChanged: (v) => _updateTimeSetting(intervals: v),
                min: 2,
                max: 10,
                color: stepperColor,
                icon: Icons.repeat,
                suffix: 'sets', // Suffix for the last field
              ),

              const SizedBox(height: 10),

              // Tutorial Link
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    // Close dialog first or push on top?
                    // Pushing on top keeps settings state, closing it feels cleaner.
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TutorialScreen(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.help_outline_rounded,
                    size: 18,
                    color: theme.colorScheme.primary.withAlpha(200),
                  ),
                  label: Text(
                    "How to use Focal",
                    style: TextStyle(
                      color: theme.colorScheme.primary.withAlpha(200),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REUSABLE WIDGETS ---

  Widget _buildOptionButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final activeBgColor = theme.colorScheme.primary;
    final activeContentColor = theme.colorScheme.onPrimary;
    final inactiveContentColor = theme.colorScheme.onSurface.withAlpha(125);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? activeContentColor : inactiveContentColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isSelected ? activeContentColor : inactiveContentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- COMPACT STEPPER WITH EDITABLE TEXT ---

class _CompactStepper extends StatefulWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final Color color;
  final IconData icon;
  final String suffix;

  const _CompactStepper({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    required this.color,
    required this.icon,
    required this.suffix,
  });

  @override
  State<_CompactStepper> createState() => _CompactStepperState();
}

class _CompactStepperState extends State<_CompactStepper> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _validateAndClamp();
    }
  }

  void _validateAndClamp() {
    int? val = int.tryParse(_controller.text);
    if (val == null) {
      // Revert if invalid
      _controller.text = widget.value.toString();
    } else {
      // Clamp value
      if (val < widget.min) val = widget.min;
      if (val > widget.max) val = widget.max;

      // Update parent if value changed
      if (val != widget.value) {
        widget.onChanged(val);
      }
      _controller.text = val.toString();
    }
  }

  @override
  void didUpdateWidget(_CompactStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controller if external change happened (e.g. buttons)
    // We check parsed controller value to avoid overwriting while user types valid numbers
    if (widget.value != oldWidget.value) {
      final currentVal = int.tryParse(_controller.text);
      if (currentVal != widget.value) {
        _controller.text = widget.value.toString();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.icon, color: widget.color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          Container(
            height: 45, // Increased height for vertical stack
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStepBtn(
                  Icons.remove,
                  widget.value > widget.min
                      ? () => widget.onChanged(widget.value - 1)
                      : null,
                  textColor,
                ),
                Container(
                  width: 65, // Increased width for text
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.color,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onTap: () {
                          _controller.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _controller.text.length,
                          );
                        },
                        onChanged: (val) {
                          final intVal = int.tryParse(val);
                          if (intVal != null) {
                            widget.onChanged(intVal);
                          }
                        },
                        onSubmitted: (_) => _validateAndClamp(),
                      ),
                      Text(
                        widget.suffix,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: widget.color.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStepBtn(
                  Icons.add,
                  widget.value < widget.max
                      ? () => widget.onChanged(widget.value + 1)
                      : null,
                  textColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepBtn(IconData icon, VoidCallback? onTap, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 42,
          height: 50, // Matched container height
          child: Icon(
            icon,
            size: 22,
            color: onTap == null ? color.withAlpha(50) : color,
          ),
        ),
      ),
    );
  }
}
