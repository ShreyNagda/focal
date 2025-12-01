import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  Future<void> playBell() async {
    try {
      final player = AudioPlayer(
        playerId: 'bell_${DateTime.now().millisecondsSinceEpoch}',
      );

      await player.play(
        AssetSource('sounds/bell.mp3'),
        mode: PlayerMode.lowLatency,
      );

      // Dispose AFTER playback finishes
      player.onPlayerComplete.first.then((_) => player.dispose());
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }
}
