import 'package:flutter/material.dart';
import 'package:music_player/pages/base_components/no_track_widget.dart';
import 'package:music_player/pages/base_components/now_playing.dart';
import 'package:music_player/pages/music_tabs/playlists.dart';
import 'package:music_player/pages/music_tabs/tracklist.dart';
import 'package:music_player/utils/api/fetch_playlists.dart';
import 'package:music_player/utils/api/fetch_tracks.dart';
import 'package:music_player/utils/api/upload.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key, required this.title});

  final String title;

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchTrackService = TrackFetchService.service;
    _playlistsFetchService = PlaylistsFetchService();
  }

  static late final TrackFetchService _fetchTrackService;
  late final PlaylistsFetchService _playlistsFetchService;
  late UploadTrackService _uploadTrackService;

  @override
  Widget build(BuildContext context) {
    _fetchTrackService.refresh();
    _playlistsFetchService.refresh();
    final colorTheme = Theme.of(context).colorScheme;

    _uploadTrackService = UploadTrackService(context);

    bool darkTheme = false;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: colorTheme.inversePrimary,
        shadowColor: colorTheme.shadow,
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              text: "Favorite",
            ),
            Tab(
              text: "Playlists",
            ),
            Tab(
              text: "Queue",
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                _fetchTrackService.refresh();
                _playlistsFetchService.refresh();
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
            TextButton(
                onPressed: () =>
                    _uploadTrackService.showUploadDialog(context).then((value) {
                      _fetchTrackService.refresh();

                      setState(() {});
                    }),
                child: const Text("Upload")),
            Switch(
              // This bool value toggles the switch.
              value: darkTheme,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (bool value) {
                // This is called when the user toggles the switch.
                setState(() {
                  darkTheme = value;
                });
              },
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TrackListPage(fetchTrackService: _fetchTrackService),
                PlaylistTab(
                  fetchPlaylistsService: _playlistsFetchService,
                ),
                const Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
              ],
            ),
          ),
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
              }),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
