import 'package:flutter/material.dart';
import 'package:music_player/track.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:developer' as dev;

import 'package:we_slide/we_slide.dart';

class PlayerWidget extends StatefulWidget {
  const PlayerWidget(
      {super.key, required this.track, required this.controller});

  final WeSlideController controller;

  final Track track;

  @override
  State<StatefulWidget> createState() => _PlayerState();
}

class _PlayerState extends State<PlayerWidget> {
  String twoDigits(int n) => n.toString().padLeft(2, "0");

  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    Track.player.positionStream.listen((event) {
      Duration temp = event as Duration;
      position = temp;
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
    return Container(
        // child: Column(
        //   children: [
        //     Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         IconButton(
        //           onPressed: () => widget.controller.hide(),
        //           icon: Icon(
        //             Icons.arrow_drop_down,
        //             size: width * 0.15,
        //           ),
        //         ),
        //         Spacer(),
        //         Text("Now playing:"),
        //         Spacer(),
        //         IconButton(
        //           onPressed: () => print("аааа"),
        //           icon: Icon(
        //             Icons.more_horiz,
        //             size: width * 0.1,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        // ),
        );
  }
}
