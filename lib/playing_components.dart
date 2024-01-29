import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_player/config.dart';
import 'package:music_player/no_track_widget.dart';
import 'package:music_player/now_playing.dart';
import 'package:music_player/track_widget.dart';
import 'dart:developer' as dev;

import 'track.dart';

class PlayingComponents {
  Function setState;

  Future<String> _future = Future(() => "2");

  PlayingComponents(this.setState) {
    _future = fetchTracks();
  }

  List<Track> tracks = List.empty(growable: true);

  int playing = 0;

  Future<String> fetchTracks() async {
    //TODO extract this shit
    return http.get(
      Uri.parse("${Config.URL}/get"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    ).then((value) {
      dev.log(value.body);
      List fetchedTracks = List.from(jsonDecode(value.body));
      tracks = List.empty(growable: true);
      if (fetchedTracks.isEmpty) return "1";
      for (var i = 0; i < fetchedTracks.length; i++) {
        tracks.add(Track(
            name: fetchedTracks[i]["name"],
            duration: Duration(seconds: fetchedTracks[i]["duration"]),
            netUrl: "${Config.URL}${fetchedTracks[i]["url"]}"));
      }
      return "0";
    });
  }

  Future<void> refresh() async {
    fetchTracks();
    setState();
  }

  Widget nowPlaying() {
    return FutureBuilder<String>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          switch (snapshot.data) {
            case "0":
              return NowPlayingWidget(
                track: tracks[playing],
                notifyParent: () {
                  setState(() {});
                },
              );
            case "1":
              return const NoTrackWidget(name: "No tracks");
            case "2":
              return const NoTrackWidget(name: "Loading");
            default:
              return const NoTrackWidget(name: "Network error");
          }
        });
  }

  Widget playingList() {
    return Container(
      color: Colors.white,
      child: FutureBuilder<String>(
        future: _future, // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          switch (snapshot.data) {
            case "0":
              return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: tracks.length,
                itemBuilder: (BuildContext context, int index) {
                  return ElevatedButton(
                      onPressed: () {
                        setState(() {
                          playing = index;
                          tracks[playing].play();
                        });
                        String trk = tracks[playing].name;
                        dev.log("$trk $playing", name: "Now playing");
                      },
                      child: TrackWidget(
                        track: tracks[index],
                      ));
                },
              );
            case "1":
              return const Text("Nothing was found.");
            case "2":
              return const Text("Loading");
            default:
              return ElevatedButton(
                  onPressed: () {
                    fetchTracks();
                  },
                  child: const Text("Refresh"));
          }
        },
      ),
    );
  }
}
