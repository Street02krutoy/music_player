import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:music_player/pages/base_components/no_track_widget.dart';
import 'package:music_player/pages/base_components/now_playing.dart';
import 'package:music_player/pages/music_tabs/playlists.dart';
import 'package:music_player/pages/playlist_page.dart';
import 'package:music_player/pages/queue_page.dart';
import 'package:music_player/utils/api/fetch_tracks.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData.light(
        useMaterial3: true,
      ),
      dark: ThemeData.dark(useMaterial3: true),
      initial: AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) => AppPage(theme, darkTheme),
    );
  }
}

class AppPage extends StatefulWidget {
  AppPage(this.light, this.dark, {super.key});

  ThemeData dark;
  ThemeData light;

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MusicPage(
          title: "Music player",
        ),
      ),
      GoRoute(
        path: '/playlists/:id',
        builder: (context, state) =>
            PlaylistPage(id: state.pathParameters['id'] ?? ""),
      ),
    ],
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    TrackFetchService.service = TrackFetchService();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: widget.light,
      darkTheme: widget.dark,
      routerConfig: _router,
    );
  }
}

/*
  FutureBuilder<String>(
            future: TrackFetchService.service.future,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              switch (snapshot.data) {
                case "0":
                  if (TrackFetchService.service.tracks. isNotEmpty) {
                    return NowPlayingWidget(
                      track: TrackFetchService
                          .service.tracks[TrackFetchService.service.playing],
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
            }),
*/