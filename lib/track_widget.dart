import 'package:flutter/material.dart';
import 'package:music_player/track.dart';

class TrackWidget extends StatefulWidget {
  const TrackWidget({super.key, required this.track});

  final Track track;

  @override
  State<StatefulWidget> createState() => _TrackWidgetState();
}

class _TrackWidgetState extends State<TrackWidget> {
  String twoDigits(int n) => n.toString().padLeft(2, "0");

  @override
  Widget build(BuildContext context) {
    Track track = widget.track;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Row(
      children: [
        Icon(
          Icons.music_note,
          size: width * 0.15,
        ),
        Text(track.name),
        const Spacer(),
        Text(
            "${twoDigits(track.duration.inMinutes.remainder(60).abs()).toString()}:${twoDigits(track.duration.inSeconds.remainder(60).abs()).toString()}"),
      ],
    );
  }
}
