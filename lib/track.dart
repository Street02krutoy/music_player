import 'package:just_audio/just_audio.dart';
import 'dart:developer' as dev;

class Track {
  Track(
      {this.name = "Untitled",
      required this.netUrl,
      this.localUrl,
      this.duration = Duration.zero});

  static final kostilPlayer = AudioPlayer();

  static final player = AudioPlayer();

  static bool playerOpened = false;

  Duration duration;
  Duration position = Duration.zero;
  bool playing = false;
  String name;
  String netUrl;
  String? localUrl;

  void playPause() async {
    playing = !playing;
    playing ? await player.play() : await player.pause();
    // if (duration == position) {

    // } else {
    //   player.seek(Duration.zero);
    //   player.play();
    // }
  }

  void stop() async {
    try {
      playing = false;
      await player.stop();
    } catch (e) {
      dev.log("pinis");
    }
  }

  void play() async {
    playing = true;
    duration = await player.setUrl(netUrl) ?? Duration.zero;
    await player.play();
  }
}
