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
  int _selectedIndex = 0;

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
        title: Text(widget.title),
        backgroundColor: colorTheme.inversePrimary,
        shadowColor: colorTheme.shadow,
        actions: [
          TextButton(
              onPressed: () =>
                  _uploadTrackService.showUploadDialog(context).then((value) {
                    _fetchTrackService.refresh();
                    setState(() {});
                  }),
              child: const Text("Upload")),
          TextButton(
              onPressed: () {
                _fetchTrackService.refresh();
                ScaffoldMessenger.of(context).showMaterialBanner(
                    MaterialBanner(content: const Text("Refreshed"), actions: [
                  TextButton(
                      onPressed:
                          ScaffoldMessenger.of(context).clearMaterialBanners,
                      child: const Text("Ok"))
                ]));
                setState(() {});
              },
              child: const Text("Reload"))
        ],
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(widget.title),
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.music_note),
                  Text(' Current track'),
                ],
              ),
              selected: _selectedIndex == 1,
              onTap: () {
                // Update the state of the app
                _onItemTapped(1);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.queue_music),
                  Text(' Current queue'),
                ],
              ),
              selected: _selectedIndex == 0,
              onTap: () {
                // Update the state of the app
                _onItemTapped(0);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.playlist_play),
                  Text('Playlists'),
                ],
              ),
              selected: _selectedIndex == 2,
              onTap: () {
                // Update the state of the app
                _onItemTapped(2);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          TrackListWidget(
            fetchTrackService: _fetchTrackService,
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
                    return const NoTrackWidget(
                        name: "No tracks (server lejit)");
                  case "1":
                    return const NoTrackWidget(name: "No tracks");
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

  void _onItemTapped(int i) {
    setState(() {
      _selectedIndex = i;
    });
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
