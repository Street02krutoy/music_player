import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:music_player/pages/base_components/playlist_widget.dart';
import 'package:music_player/utils/api/fetch_playlists.dart';
import 'package:music_player/utils/entities/playlist.dart';

class PlaylistTab extends StatefulWidget {
  const PlaylistTab({super.key, required this.fetchPlaylistsService});
  final PlaylistsFetchService fetchPlaylistsService;

  @override
  State<PlaylistTab> createState() => _PlaylistTabState();
}

class _PlaylistTabState extends State<PlaylistTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PlaylistsFetchService service = widget.fetchPlaylistsService;
    return FutureBuilder(
      future: service.future,
      builder: (BuildContext ctx, AsyncSnapshot<String> snapshot) =>
          GridView.count(
        crossAxisCount: 2,
        children: List.generate(service.playlists.length, (index) {
          return Center(
            child: PlaylistWidget(
                playlist: service.playlists[index],
                onPressed: () =>
                    {context.go("/playlists/${service.playlists[index].id}")}),
          );
        }),
      ),
    );
  }
}
