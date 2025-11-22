# 🍅 Focal Timer

Focal is a modern, aesthetic Pomodoro timer application built with Flutter. It is designed to help you stay focused and productive by using the Pomodoro Technique, managing your work sessions and breaks efficiently.

## ✨ Features

- **Multiple Timer Modes:**
  - **Focus Time:** Default 25-minute work blocks.
  - **Short Break:** 5-minute breaks to recharge.
  - **Long Break:** 15-minute breaks after completing a set of pomodoros.
- **Dual Timer Views:** Switch seamlessly between a **Modern Circular Timer** and a **Retro Flip Clock**.
- **Background Execution:** The timer runs accurately in the background even when the app is closed, thanks to a robust background service.
- **Smart Notifications:**
  - **Sticky Notification:** Shows live progress while the timer is running in the background.
  - **Completion Alerts:** Notifies you when a session ends with sound and tells you exactly what comes next (e.g., "Up Next: Short Break").
- **Customizable Settings:** Adjust durations for work, short breaks, and long breaks to suit your workflow.
- **Audio Feedback:** Plays a bell sound upon session completion.
- **Productivity Tracking:** Tracks completed sessions and progress towards daily goals.
- **Beautiful Dark UI:** Designed with a clean, OLED-friendly dark theme and electric blue accents.

## 📱 Screenshots

| Circular View | Flip View |
| :-----------: | :-------: |
|               |           |

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Local Storage:** [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Notifications:** [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- **Background Task:** [Flutter Background Service](https://pub.dev/packages/flutter_background_service)
- **Audio:** [AudioPlayers](https://pub.dev/packages/audioplayers)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (Latest Stable)
- Dart SDK
- Android Studio / VS Code
- An Android device or emulator (Android 12+ recommended for exact alarm testing)

### Installation

1.  **Clone the repository:**

    ```bash
    git clone [https://github.com/yourusername/focal-timer.git](https://github.com/yourusername/focal-timer.git)
    cd focal-timer
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    flutter run
    ```


📂 Project Structure
lib/
├── constants/
│ ├── app_colors.dart # Application color palette
│ └── app_keys.dart # Prefs keys and notification IDs
├── models/
│ ├── productivity_data.dart # Data models for stats
│ └── timer_state.dart # State model for the timer logic
├── providers/
│ └── timer_provider.dart # Main business logic (Provider)
├── screens/
│ ├── widgets/
│ │ ├── circular_timer.dart
│ │ ├── flip_timer.dart
│ │ └── settings_dialog.dart
│ └── home_screen.dart # Main UI
├── services/
│ ├── audio_service.dart # Sound management
│ ├── background_service.dart# Background isolate handling
│ └── notification_service.dart # Local notifications handler
└── main.dart # Entry point

🤝 Contributing
Contributions are welcome! Please fork the repository and create a pull request for any features or bug fixes.

📄 License
This project is open-source and available under the MIT License.
