import 'package:flutter/material.dart';
import 'package:music_player/config.dart';
import 'package:music_player/no_track_widget.dart';
import 'package:music_player/now_playing.dart';
import 'package:music_player/track.dart';
import 'package:music_player/track_widget.dart';
import 'package:http/http.dart' as http;
import 'package:music_player/utils/upload.dart';
import 'dart:convert';
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
  List<Track> tracks = List.empty();

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
      if (fetchedTracks.isEmpty) return "1";
      for (var i = 0; i < fetchedTracks.length; i++) {
        trks.add(Track(
            name: fetchedTracks[i]["name"],
            duration: Duration(seconds: fetchedTracks[i]["duration"]),
            netUrl: "${Config.URL}${fetchedTracks[i]["url"]}"));
      }
      tracks = trks;
      return "0";
    });
  }

  Future<String> _future = Future(
    () => "",
  );

  @override
  void initState() {
    super.initState();
    _future = fetchTracks();
  }

  int playing = 0;

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;

    UploadTrackService uploadTrackService = UploadTrackService(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AppBar Demo'),
        backgroundColor: colorTheme.inversePrimary,
        shadowColor: colorTheme.shadow,
        actions: [
          TextButton(
              onPressed: () => uploadTrackService.showUploadDialog(context),
              child: const Text("Upload")),
          TextButton(
              onPressed: () {
                fetchTracks();
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
              future: _future, // a previously-obtained Future<String> or null
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                return snapshot.data == "0"
                    ? tracks.isEmpty
                        ? const Text("")
                        : ListView.builder(
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

                                    dev.log("$trk $playing",
                                        name: "Now playing");
                                  },
                                  child: TrackWidget(
                                    track: tracks[index],
                                  ));
                            },
                          )
                    : ElevatedButton(
                        onPressed: () {
                          fetchTracks();
                        },
                        child: const Text("Refresh"));
              },
            ),
          ),
          const Spacer(),
          FutureBuilder<String>(
              future: _future,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                return snapshot.data == "0"
                    ? NowPlayingWidget(
                        track: tracks[playing],
                        notifyParent: () {
                          setState(() {});
                        },
                      )
                    : snapshot.data == "1"
                        ? const NoTrackWidget(name: "No tracks")
                        : const NoTrackWidget(name: "Network error");
              })
        ],
      ),
    );
  }
}
