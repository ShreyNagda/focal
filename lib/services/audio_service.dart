import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  Future<void> playBell() async {
    try {
      final player = AudioPlayer(
        playerId: 'bell_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (kIsWeb) {
        await player.play(UrlSource('assets/sounds/bell.mp3'));
      } else {
        await player.play(AssetSource('sounds/bell.mp3'));
      }

      // Automatically Dispose AFTER playback finishes
      // No dispose method required
      player.onPlayerComplete.first.then((_) => player.dispose());
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }
}
