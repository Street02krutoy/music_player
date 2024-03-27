import 'package:flutter/material.dart';
import 'package:music_player/pages/tracklist.dart';
import 'package:music_player/utils/api/fetch.dart';
import 'package:music_player/utils/api/upload.dart';

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
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        bottom: TabBar(
          controller: TabController(length: 3, vsync: this),
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.cloud_outlined),
              text: "All tracks",
            ),
            Tab(
              icon: Icon(Icons.beach_access_sharp),
              text: "Playlists",
            ),
            Tab(
              icon: Icon(Icons.brightness_5_sharp),
              text: "Queue",
            ),
          ],
        ),
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
      body: TrackListPage(fetchTrackService: _fetchTrackService),
    );
  }

  void _onItemTapped(int i) {
    setState(() {
      _selectedIndex = i;
    });
  }
}
