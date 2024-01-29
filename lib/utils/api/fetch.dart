import 'package:http/http.dart' as http;
import 'package:music_player/config.dart';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:music_player/track.dart';

class FetchTrackService {
  List<Track> tracks = List.empty();
  int playing = 0;
  Future<String> future = Future(() => "0");

  void refresh() {
    future = fetchTracks();
  }

  Future<String> fetchTracks() async {
    return http.get(
      Uri.parse("${Config.URL}/get"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    ).then((value) {
      dev.log(value.body);
      List fetchedTracks = List.from(jsonDecode(value.body));
      List<Track> trks = List.empty(growable: true);
      for (var i = 0; i < fetchedTracks.length; i++) {
        trks.add(Track(
            name: fetchedTracks[i]["name"],
            duration: Duration(seconds: fetchedTracks[i]["duration"]),
            netUrl: "${Config.URL}${fetchedTracks[i]["url"]}"));
      }
      tracks = trks;
      if (tracks.isEmpty) return "1";
      return "0";
    }).catchError((value) => "2");
  }
}
