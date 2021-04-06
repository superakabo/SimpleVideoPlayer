import 'package:flutter/material.dart';
import 'package:simple_video_player/simple_video_player.dart';
import 'package:simple_video_player/simple_video_player_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Video Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey.shade100,
        primaryColorBrightness: Brightness.light,
        brightness: Brightness.light,
      ),
      home: Example(),
    );
  }
}

class Example extends StatefulWidget {
  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> with SingleTickerProviderStateMixin {
  late final _videoPlayerController = SimpleVideoPlayerController.fromNetwork(
    'https://storage.googleapis.com/whatsad-84167.appspot.com/ads/p835.mp4',
    thumbnail: 'https://storage.googleapis.com/whatsad-84167.appspot.com/ads/p835.jpg',
  );
  late final _animationController = AnimationController(vsync: this);

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SimpleVideoPlayer(
        videoPlayerController: _videoPlayerController,
        autoDispose: false,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Play / Pause',
        child: AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: _animationController,
        ),
        onPressed: () async {
          (_videoPlayerController.value.isPlaying) ? _videoPlayerController.pause() : _videoPlayerController.play();
        },
      ),
    );
  }
}
