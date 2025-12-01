import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
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
    final prefs = await SharedPreferences.getInstance();
    await StorageService(prefs).setHasSeenTutorial();

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define Max Width for content containment on large screens
    const double maxWidth = 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Close/Skip
            Padding(
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
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Main Content (Constrained PageView)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: maxWidth),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.icon,
                                size: 80,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 48),
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              item.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: colorScheme.onSurface.withAlpha(178),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page Indicators
                    Row(
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
                    ),

                    // Next/Done Button
                    FloatingActionButton(
                      onPressed: _onNext,
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 2,
                      child: Icon(
                        _currentPage == _items.length - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
