import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import 'home_screen.dart';

class TutorialItem {
  final String title;
  final String description;
  final IconData icon;

  const TutorialItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialItem> _items = const [
    TutorialItem(
      title: 'Set Precise Durations',
      description:
          'In Settings, tap the time value to type a custom duration, or use the +/- buttons for quick adjustments. Values update instantly!',
      icon: Icons.access_time_filled,
    ),
    TutorialItem(
      title: 'Personalize Style & Sound',
      description:
          'Toggle your Clock Style (Flip or Circle) and set your preferred Theme (Light, Dark, or System) to make the app your own.',
      icon: Icons.style,
    ),
    TutorialItem(
      title: 'Engage the Session',
      description:
          'Tap the large central button to START your Focus block. The timer continues to run in the background with native notifications.',
      icon: Icons.play_circle_fill,
    ),
    TutorialItem(
      title: 'Monitor Progress',
      description:
          'The small dots below the timer track your Focus intervals. Complete your sets to earn a Long Break automatically.',
      icon: Icons.track_changes,
    ),
    TutorialItem(
      title: 'Re-run Tutorial',
      description:
          'If you need a refresher, tap the Settings icon (gear) and select "Re-run Tutorial" at the bottom of the dialog.',
      icon: Icons.school,
    ),
  ];

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  Future<void> _completeTutorial() async {
    final timerProvider = context.read<TimerProvider>();
    await timerProvider.completeTutorial();

    if (!mounted) return;

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _onNext() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
    }
  }

  // --- Helper Widgets ---

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (Navigator.canPop(context))
            IconButton(
              icon: Icon(Icons.close, color: theme.iconTheme.color),
              onPressed: () => Navigator.pop(context),
            )
          else
            const SizedBox(width: 48),

          if (_currentPage < _items.length - 1)
            TextButton(
              onPressed: _completeTutorial,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _items.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 8),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? colorScheme.primary
                : colorScheme.onSurface.withAlpha(51),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(ColorScheme colorScheme) {
    return FloatingActionButton(
      onPressed: _onNext,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 2,
      child: Icon(
        _currentPage == _items.length - 1 ? Icons.check : Icons.arrow_forward,
      ),
    );
  }

  Widget _buildTutorialPage(
    BuildContext context,
    ColorScheme colorScheme,
    TutorialItem item,
    double maxWidth,
    bool isLandscape,
  ) {
    // --- Reusable Icon Block ---
    final iconBlock = Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.primary.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Icon(item.icon, size: 80, color: colorScheme.primary),
    );

    // --- Reusable Text Block ---
    final textBlock = Column(
      mainAxisAlignment: isLandscape
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      crossAxisAlignment: isLandscape
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      mainAxisSize: isLandscape ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (isLandscape)
          const SizedBox(height: 16), // Padding adjustment for landscape

        Text(
          item.title,
          textAlign: isLandscape ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          item.description,
          textAlign: isLandscape ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: colorScheme.onSurface.withAlpha(178),
          ),
        ),
        if (isLandscape)
          const SizedBox(height: 16), // Padding adjustment for landscape
      ],
    );

    return Center(
      child: ConstrainedBox(
        // Use a smaller maxWidth in landscape to prevent text from spreading too wide
        constraints: BoxConstraints(maxWidth: isLandscape ? 800 : maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: isLandscape
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon on the left
                    iconBlock,
                    const SizedBox(width: 48), // Spacing between icon and text
                    // Text on the right (takes remaining space)
                    Expanded(child: textBlock),
                  ],
                )
              : Column(
                  // Icon on top, Text below for portrait mode
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    iconBlock,
                    const SizedBox(height: 48), // Spacing between icon and text
                    textBlock,
                  ],
                ),
        ),
      ),
    );
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define Max Width for content containment on large screens
    const double maxWidth = 600;

    // Build the fixed Header
    final header = _buildHeader(context, theme);

    // Build the Navigation/Footer Controls
    final navControls = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPageIndicators(colorScheme),
            _buildNextButton(colorScheme),
          ],
        ),
      ),
    );

    // REVISED: Define the PageView builder ONLY (without the Expanded wrapper)
    final corePageViewContent = PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;

        return _buildTutorialPage(
          context,
          colorScheme,
          item,
          maxWidth,
          isLandscape,
        );
      },
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;

            // --- LAYOUT STRUCTURE ---
            return Column(
              children: [
                header, // Header always on top
                // Conditional Layout for PageView and Controls
                if (isLandscape)
                  // LANDSCAPE: PageView and Controls arranged vertically in the main column
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          // FIX 1: This Expanded is necessary to constrain the PageView
                          child: corePageViewContent, // Now wrapped only once
                        ),
                        navControls, // Controls are placed below the page content
                      ],
                    ),
                  )
                else
                  // PORTRAIT: PageView takes remaining space, controls at the very bottom
                  Expanded(
                    // FIX 2: This Expanded now wraps the Column containing PageView and controls
                    child: Column(
                      children: [
                        Expanded(
                          child: corePageViewContent,
                        ), // PageView expands
                        navControls, // Controls are placed below the page content
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
