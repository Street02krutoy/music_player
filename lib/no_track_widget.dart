import 'package:flutter/material.dart';
import 'package:music_player/track.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:developer' as dev;

class NoTrackWidget extends StatelessWidget {
  const NoTrackWidget({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        LinearPercentIndicator(
          percent: 0,
          width: width,
          lineHeight: 12,
          animation: true,
          animateFromLastPercent: true,
          progressColor: Colors.blue,
          padding: EdgeInsets.zero,
        ),
        Row(
          children: [
            Icon(
              Icons.music_note,
              size: width * 0.15,
            ),
            Text(this.name),
            const Spacer(),
            Text("00:00\n00:00"),
            Icon(
              Icons.play_arrow,
              size: width * 0.15,
            ),
          ],
        ),
      ],
    );
  }
}
