import 'package:flutter/material.dart';
import 'package:music_player/no_track_widget.dart';
import 'package:music_player/now_playing.dart';
import 'package:music_player/track_widget.dart';
import 'dart:developer' as dev;

import '../utils/api/fetch.dart';

class TrackListPage extends StatefulWidget {
  const TrackListPage({super.key, required this.fetchTrackService});

  final FetchTrackService fetchTrackService;
  @override
  State<TrackListPage> createState() => _TrackListPageState();
}

class _TrackListPageState extends State<TrackListPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TrackListWidget(
          fetchTrackService: widget.fetchTrackService,
        ),
        const Spacer(),
        FutureBuilder<String>(
            future: widget.fetchTrackService.future,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              switch (snapshot.data) {
                case "0":
                  if (widget.fetchTrackService.tracks.isNotEmpty) {
                    return NowPlayingWidget(
                      track: widget.fetchTrackService
                          .tracks[widget.fetchTrackService.playing],
                      notifyParent: () {
                        setState(() {});
                      },
                    );
                  }
                  return const NoTrackWidget(name: "No tracks (server lejit)");
                case "1":
                  return const NoTrackWidget(name: "No tracks");
                case "2":
                  return const NoTrackWidget(name: "Network error");
                default:
                  return const NoTrackWidget(name: "Unexpected error");
              }
            })
      ],
    );
  }
}

class TrackListWidget extends StatefulWidget {
  const TrackListWidget({super.key, required this.fetchTrackService});

  final FetchTrackService fetchTrackService;

  @override
  State<TrackListWidget> createState() => _TrackListWidgetState();
}

class _TrackListWidgetState extends State<TrackListWidget> {
  @override
  Widget build(BuildContext context) {
    FetchTrackService service = widget.fetchTrackService;

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
                        service.playing = index;
                        service.tracks[service.playing].play();
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
