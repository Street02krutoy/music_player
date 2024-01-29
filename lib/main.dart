import 'package:flutter/material.dart';
import 'package:music_player/no_track_widget.dart';
import 'package:music_player/now_playing.dart';
import 'package:music_player/track_widget.dart';
import 'package:music_player/utils/api/fetch.dart';
import 'package:music_player/utils/api/upload.dart';
import 'dart:developer' as dev;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _fetchTrackService = FetchTrackService();
  }

  late final FetchTrackService _fetchTrackService;
  late UploadTrackService _uploadTrackService;

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;

    _uploadTrackService = UploadTrackService(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AppBar Demo'),
        backgroundColor: colorTheme.inversePrimary,
        shadowColor: colorTheme.shadow,
        actions: [
          TextButton(
              onPressed: () => _uploadTrackService.showUploadDialog(context),
              child: const Text("Upload")),
          TextButton(
              onPressed: () {
                _fetchTrackService.refresh();
                setState(() {});
              },
              child: const Text("Reload"))
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: FutureBuilder<String>(
              future: _fetchTrackService
                  .future, // a previously-obtained Future<String> or null
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                switch (snapshot.data) {
                  case "0":
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: _fetchTrackService.tracks.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _fetchTrackService.playing = index;
                                _fetchTrackService
                                    .tracks[_fetchTrackService.playing]
                                    .play();
                              });
                              String trk = _fetchTrackService
                                  .tracks[_fetchTrackService.playing].name;

                              dev.log("$trk ${_fetchTrackService.playing}",
                                  name: "Now playing");
                            },
                            child: TrackWidget(
                              track: _fetchTrackService.tracks[index],
                            ));
                      },
                    );
                  default:
                    return const Text("");
                }
              },
            ),
          ),
          const Spacer(),
          FutureBuilder<String>(
              future: _fetchTrackService.future,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                switch (snapshot.data) {
                  case "0":
                    if (_fetchTrackService.tracks.isNotEmpty) {
                      return NowPlayingWidget(
                        track: _fetchTrackService
                            .tracks[_fetchTrackService.playing],
                        notifyParent: () {
                          setState(() {});
                        },
                      );
                    }
                    return const NoTrackWidget(name: "No tracks");
                  case "1":
                    return const NoTrackWidget(name: "Error: No tracks");
                  case "2":
                    return const NoTrackWidget(name: "Network error");
                  default:
                    return const NoTrackWidget(name: "Unexpected error");
                }
              })
        ],
      ),
    );
  }
}
