import 'dart:convert';

class AppConfig {
  final bool isFlipStyle;
  final bool isSoundEnabled;
  final String themeMode; // 'system', 'light', 'dark'

  const AppConfig({
    this.isFlipStyle = true,
    this.isSoundEnabled = true,
    this.themeMode = 'light',
  });

  AppConfig copyWith({
    bool? isFlipStyle,
    bool? isSoundEnabled,
    String? themeMode,
  }) {
    return AppConfig(
      isFlipStyle: isFlipStyle ?? this.isFlipStyle,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isFlipStyle': isFlipStyle,
      'isSoundEnabled': isSoundEnabled,
      'themeMode': themeMode,
    };
  }

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      isFlipStyle: map['isFlipStyle'] ?? true,
      isSoundEnabled: map['isSoundEnabled'] ?? true,
      themeMode: map['themeMode'] ?? 'light',
    );
  }

  String toJson() => json.encode(toMap());

  factory AppConfig.fromJson(String source) =>
      AppConfig.fromMap(json.decode(source));
}
