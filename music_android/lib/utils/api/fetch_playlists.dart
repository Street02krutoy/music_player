import 'dart:convert';
import 'dart:developer';

import 'package:music_player/utils/config.dart';
import 'package:http/http.dart' as http;
import 'package:music_player/utils/entities/playlist.dart';

import '../entities/track.dart';

class PlaylistsFetchService {
  List<Playlist> playlists = List.empty();
  int playing = 0;
  Future<String> future = Future(() => "0");

  void refresh() {
    future = fetchTracks();
  }

  Future<String> fetchTracks() {
    return http
        .get(
      Uri.parse(Config.playlistEndpoints.get),
    )
        .then((value) {
      List<dynamic> fetchedPlsts = jsonDecode(value.body);
      print(fetchedPlsts.toString());
      List<Playlist> plsts = List.empty(growable: true);
      for (var e = 0; e < fetchedPlsts.length; e++) {
        plsts.add(Playlist(
            name: fetchedPlsts[e]["name"],
            tracks: List.empty(),
            id: fetchedPlsts[e]["id"]));
      }

      playlists = plsts;
      log(playlists.toString());
      return "0";
    });
  }
}
