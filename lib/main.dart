import 'dart:io';

import 'package:file_picker/file_picker.dart';
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

  final uri = 'http://192.168.0.106:8080';

  Future<String> fetchTracks() async {
    print("any");
    return http.get(
      Uri.parse(uri + "/get"),
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
            netUrl: "$uri${fetchedTracks[i]["url"]}"));
      }
      tracks = trks;
      return "0";
    });
  }

  final TextEditingController _controller = TextEditingController();

  late File track;

  Future<void> _showUploadDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload a file'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextButton(
                  child: const Text('Select'),
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();

                    if (result != null) {
                      if (result.count == 1 &&
                          result.names[0]!.endsWith(".mp3")) {
                        track = File(result.files.single.path!);

                        return;
                      }
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('File is not ends with .mp3'),
                      ));
                      return;
                    } else {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('File hasn`t choosen'),
                      ));
                    }
                  },
                ),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: "track name"),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Upload'),
              onPressed: () async {
                var request =
                    http.MultipartRequest("POST", Uri.parse('$uri/upload'));
                //request.fields['name'] = _controller.text;
                request.files
                    .add(await http.MultipartFile.fromPath("file", track.path));
                print(track.path);

                var response =
                    await http.Response.fromStream(await request.send());
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Uploaded!'),
                  ));

                  print("$uri/update/${jsonDecode(response.body)["id"]}");

                  http.put(
                      Uri.parse(
                        "$uri/update/${jsonDecode(response.body)["id"]}",
                      ),
                      body: '{"name":"${_controller.text}"}',
                      headers: {
                        "Content-Type": "application/json"
                      }).then((value) => print(value.statusCode));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${response.statusCode} ne Uploaded!'),
                  ));
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
    final colorTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AppBar Demo'),
        backgroundColor: colorTheme.inversePrimary,
        shadowColor: colorTheme.shadow,
        actions: [
          TextButton(onPressed: _showUploadDialog, child: Text("Upload")),
          TextButton(
              onPressed: () {
                fetchTracks();
                setState(() {});
              },
              child: Text("Reload"))
        ],
      ),
      body: Column(
        children: [
          Container(
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
