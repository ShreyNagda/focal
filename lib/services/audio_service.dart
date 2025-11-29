import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playBell() async {
    try {
      // Stop any currently playing sound to allow rapid replay
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/bell.mp3'));
    } catch (e) {
      print(e);
      debugPrint("Error playing sound: $e");
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
