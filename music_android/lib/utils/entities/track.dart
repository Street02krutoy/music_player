import 'package:just_audio/just_audio.dart';
import 'dart:developer' as dev;

import 'package:music_player/utils/entities/playlist.dart';

class Track {
  Track(
      {this.name = "Untitled",
      required this.netUrl,
      this.localUrl,
      this.duration = Duration.zero});

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

  void play(List<Track>? tracks, int? startIndex) async {
    if (tracks == null) {
      playing = true;
      duration = await player.setUrl(netUrl) ?? Duration.zero;
      await player.play();
    } else {
      List<AudioSource> audioSources = List.empty(growable: true);

      for (var i = 0; i < tracks.length; i++) {
        audioSources.add(AudioSource.uri(Uri.parse(tracks[i].netUrl)));
      }

      final playlist = ConcatenatingAudioSource(
        // Start loading next item just before reaching it
        useLazyPreparation: true,
        // Specify the playlist items
        children: audioSources,
      );

// Load and play the playlist
      await player.setAudioSource(playlist,
          initialIndex: startIndex, initialPosition: Duration.zero);
    }
  }
}
