import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // --- Colors ---
  // Toned-down Pomodoro Red (Slightly darker and less saturated than 0xFFE53935)
  static const Color pomodoroRed = Color(0xFFD32F2F);
  static const Color tealAccent = Color(0xFF26A69A);
  static const Color blueAccent = Color(0xFF42A5F5);

  // Dark Palette (Existing)
  static const Color darkBackground = Color(0xFF1F1F1F);
  static const Color darkSurface = Color(0xFF2C2C2C);
  static const Color darkCard = Color(0xFF333333);
  static const Color darkText = Color(0xFFE5E5EA);

  // Light Palette (Concrete Style)
  static const Color lightBackground = Color(0xFFE0E0E0);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF212121);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: CupertinoColors.darkBackgroundGray,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: CupertinoColors.darkBackgroundGray,
        secondary: tealAccent,
        surface: lightSurface,
        onSurface: lightText,
        tertiaryContainer: lightCard,
        onTertiaryContainer: lightText,
      ),
      iconTheme: const IconThemeData(color: lightText),
      textTheme: Typography.blackMountainView.apply(fontFamily: 'Roboto'),
      dialogTheme: const DialogThemeData(backgroundColor: lightSurface),
      dividerColor: Colors.black12,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: CupertinoColors.lightBackgroundGray,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: CupertinoColors.lightBackgroundGray,
        secondary: tealAccent,
        surface: darkSurface,
        onSurface: darkText,
        tertiaryContainer: darkCard,
        onTertiaryContainer: darkText,
      ),
      iconTheme: const IconThemeData(color: darkText),
      textTheme: Typography.whiteMountainView.apply(fontFamily: 'Roboto'),
      dialogTheme: const DialogThemeData(backgroundColor: darkSurface),
      dividerColor: Colors.white10,
    );
  }
}
