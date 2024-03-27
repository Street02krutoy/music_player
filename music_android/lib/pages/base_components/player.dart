import 'package:flutter/material.dart';
import 'package:music_player/utils/entities/track.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:we_slide/we_slide.dart';

class PlayerWidget extends StatefulWidget {
  const PlayerWidget(
      {super.key,
      required this.track,
      required this.controller,
      required this.notifyParent});

  final Function() notifyParent;

  final WeSlideController controller;

  final Track track;

  @override
  State<StatefulWidget> createState() => _PlayerState();
}

class _PlayerState extends State<PlayerWidget> {
  String twoDigits(int n) => n.toString().padLeft(2, "0");

  late bool jopa = false;

  @override
  void initState() {
    widget.controller.addListener(() {
      jopa = widget.controller.value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    jopa = widget.controller.value;
    print(widget.controller.isOpened);
    Track track = widget.track;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var mins = twoDigits(track.duration.inMinutes.remainder(60).abs());
    var secs = twoDigits(track.duration.inSeconds.remainder(60).abs());
    return Container(
      child: jopa
          ? Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        widget.controller.hide();
                        widget.notifyParent();
                      },
                      icon: Icon(
                        Icons.arrow_drop_down,
                        size: width * 0.15,
                      ),
                    ),
                    Spacer(),
                    Text("Now playing:"),
                    Spacer(),
                    IconButton(
                      onPressed: () => print("аааа"),
                      icon: Icon(
                        Icons.more_horiz,
                        size: width * 0.1,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(),
    );
  }
}
