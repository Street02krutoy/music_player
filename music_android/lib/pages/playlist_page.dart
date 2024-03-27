import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:music_player/pages/base_components/track_widget.dart';
import 'package:music_player/utils/api/fetch_tracks.dart';
import 'package:music_player/utils/entities/track.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key, required this.id});

  final String id;

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    service = PlaylistTrackFetchService(id: widget.id);
  }

  late PlaylistTrackFetchService service;
  @override
  Widget build(BuildContext context) {
    service.refresh();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
                onPressed: () {
                  context.go("/");
                },
                icon: const Icon(Icons.arrow_back)),
            Text(service.name ?? "Playlist")
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                service.refresh();
                ScaffoldMessenger.of(context).showMaterialBanner(
                    MaterialBanner(content: const Text("Refreshed"), actions: [
                  TextButton(
                      onPressed:
                          ScaffoldMessenger.of(context).clearMaterialBanners,
                      child: const Text("Ok"))
                ]));
                setState(() {});
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder<String>(
        future: service.future,
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

                        log("$trk ${service.playing}", name: "Now playing");
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
      ),
    );
  }
}
