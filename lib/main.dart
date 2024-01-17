import 'package:flutter/material.dart';
import 'package:music_player/no_track_widget.dart';
import 'package:music_player/now_playing.dart';
import 'package:music_player/player.dart';
import 'package:music_player/track.dart';
import 'package:music_player/track_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:we_slide/we_slide.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
    print("any");
    const uri = 'http://192.168.0.106:3000';
    return http.get(
      Uri.parse(uri),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    ).then((value) {
      dev.log(value.body);
      List names = List.from(jsonDecode(value.body));
      List<Track> trks = List.empty(growable: true);
      for (var i = 0; i < names.length; i++) {
        print(names[i]);
        trks.add(Track(
            name: names[i]["name"],
            duration:
                Duration(seconds: (names[i]["duration"] as double).toInt()),
            netUrl: "$uri/tracks/$i.mp3"));
      }
      tracks = trks;
      return "0";
    }).catchError(() => "1");
    // tracks = List.filled(
    //     1,
    //     Track(
    //         netUrl: "https://www.myinstants.com/media/sounds/ba-dum.mp3",
    //         name: "бадабуспссс саунд"));
    // return Future(
    //   () => "0",
    // );
  }

  Future<String> _future = Future(
    () => "",
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _future = fetchTracks();
  }

  int playing = 0;

  @override
  Widget build(BuildContext context) {
    final _controller = WeSlideController();
    final colorTheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: WeSlide(
          parallax: true,
          hideAppBar: false,
          hideFooter: false,
          panelMinSize: 80.0,
          isDismissible: false,
          panelMaxSize: MediaQuery.of(context).size.height,
          backgroundColor: Colors.white,
          isUpSlide: true,
          parallaxOffset: 0.5,
          appBarHeight: 80.0,
          footerHeight: 100.0,
          hidePanelHeader: true,
          controller: _controller,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
          ),
          body: Container(
            color: Colors.white,
            child: FutureBuilder<String>(
              future: _future, // a previously-obtained Future<String> or null
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                List<Widget> children;
                return snapshot.data == "0"
                    ? tracks.isEmpty
                        ? Text("")
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
                        child: Text("Refresh"));
              },
            ),
          ),
          panel: Container(
            child: PlayerWidget(
                controller: _controller,
                track: tracks.isNotEmpty ? tracks[playing] : Track(netUrl: ""),
                notifyParent: () {
                  setState(() {});
                }),
          ),
          panelHeader: Container(
            child: FutureBuilder<String>(
                future: _future,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  return snapshot.data == "0"
                      ? NowPlayingWidget(
                          track: tracks[playing],
                          controller: _controller,
                          notifyParent: () {
                            setState(() {});
                          },
                        )
                      : const NoTrackWidget(name: "Network error");
                }),
          )),
    );
  }
}
