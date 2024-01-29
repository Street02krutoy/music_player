import 'package:flutter/material.dart';
import 'package:music_player/playing_components.dart';
import 'package:music_player/utils/upload.dart';

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
  @override
  void initState() {
    super.initState();
    uploadTrackService = UploadTrackService(context);
    playingComponents = PlayingComponents((Function fun) {
      setState(() {
        fun();
      });
    });
  }

  int playing = 0;

  late UploadTrackService uploadTrackService;

  late PlayingComponents playingComponents;
  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppBar Demo'),
        backgroundColor: colorTheme.inversePrimary,
        shadowColor: colorTheme.shadow,
        actions: [
          TextButton(
              onPressed: () => uploadTrackService.showUploadDialog,
              child: const Text("Upload")),
          TextButton(
              onPressed: playingComponents.refresh, child: const Text("Reload"))
        ],
      ),
      body: Column(
        children: [
          playingComponents.playingList(),
          const Spacer(),
          playingComponents.nowPlaying()
        ],
      ),
    );
  }
}
