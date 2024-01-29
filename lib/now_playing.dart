import 'package:flutter/material.dart';
import 'package:music_player/track.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:developer' as dev;

import 'package:we_slide/we_slide.dart';

class NowPlayingWidget extends StatefulWidget {
  final Function() notifyParent;
  const NowPlayingWidget({
    super.key,
    required this.track,
    required this.notifyParent,
  });

  final Track track;

  @override
  State<StatefulWidget> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlayingWidget> {
  String twoDigits(int n) => n.toString().padLeft(2, "0");

  @override
  void initState() {
    Track track = widget.track;
    super.initState();
    Track.player.positionStream.listen((event) {
      Duration temp = event as Duration;
      track.position = temp;
      if (track.position == track.duration) {
        track.playing = false;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Track track = widget.track;

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var mins = twoDigits(track.duration.inMinutes.remainder(60).abs());
    var secs = twoDigits(track.duration.inSeconds.remainder(60).abs());
    return Column(
      children: [
        LinearPercentIndicator(
          percent: track.position.inSeconds / track.duration.inSeconds,
          width: width,
          lineHeight: 12,
          animation: true,
          animateFromLastPercent: true,
          progressColor: Colors.blue,
          padding: EdgeInsets.zero,
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.music_note,
                size: width * 0.15,
              ),
            ),
            Text(track.name),
            const Spacer(),
            Text(
                "${twoDigits(track.position.inMinutes.remainder(60).abs())}:${twoDigits(track.position.inSeconds.remainder(60).abs())}\n$mins:$secs"),
            IconButton(
                onPressed: () {
                  setState(() {
                    track.playPause();
                  });
                  print(track.playing);
                },
                icon: Icon(
                  track.playing ? Icons.pause_circle : Icons.play_arrow,
                  size: width * 0.15,
                )),
          ],
        ),
      ],
    );
  }
}
