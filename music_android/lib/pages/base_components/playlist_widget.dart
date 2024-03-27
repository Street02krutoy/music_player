import 'package:flutter/material.dart';
import 'package:music_player/utils/entities/playlist.dart';

class PlaylistWidget extends StatelessWidget {
  PlaylistWidget({super.key, required this.playlist, required this.onPressed});

  Playlist playlist;
  void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SizedBox(
      width: width * 0.45,
      height: width * 0.45,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              // Change your radius here
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Column(
          children: [
            Icon(
              Icons.playlist_play,
              size: width * 0.25,
            ),
            Text(playlist.name),
          ],
        ),
      ),
    );
  }
}
