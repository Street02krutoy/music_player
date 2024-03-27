import 'package:music_player/utils/entities/track.dart';

class Playlist {
  final String name;
  final List<Track> tracks;
  final String id;

  Playlist({required this.name, required this.tracks, required this.id});
}
