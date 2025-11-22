import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playBell() async {
    try {
      await _player.play(AssetSource('sounds/bell.mp3'));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  static Future<void> stopBell() async {
    await _player.stop();
  }

  static void dispose() {
    _player.dispose();
  }
}
