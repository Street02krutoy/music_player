import 'package:flutter/material.dart';
import 'package:music_player/pages/base_components/no_track_widget.dart';
import 'package:music_player/pages/base_components/now_playing.dart';
import 'package:music_player/pages/base_components/track_widget.dart';
import 'package:music_player/utils/entities/track.dart';
import 'dart:developer' as dev;

import '../../utils/api/fetch_tracks.dart';

class TrackListPage extends StatefulWidget {
  const TrackListPage({super.key, required this.fetchTrackService});

  final TrackFetchService fetchTrackService;

  @override
  State<TrackListPage> createState() => _TrackListPageState();
}

class _TrackListPageState extends State<TrackListPage> {
  @override
  Widget build(BuildContext context) {
    TrackFetchService service = widget.fetchTrackService;

    return FutureBuilder<String>(
      future: service.future, // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.data) {
          case "0":
            return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: service.tracks.length,
              itemBuilder: (BuildContext context, int index) {
                return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        var trk = service.tracks[service.playing];
                        service.playing = index;
                        trk.play([trk], 0);
                      });
                      String trk = service.tracks[service.playing].name;

                      dev.log("$trk ${service.playing}", name: "Now playing");
                    },
                    child: TrackWidget(
                      track: service.tracks[index],
                    ));
              },
            );
          default:
            return const Text("");
        }
      },
    );
  }
}
